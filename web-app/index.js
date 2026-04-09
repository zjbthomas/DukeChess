"use strict";

require('dotenv').config();

const express = require("express");
const http = require("http");
const { Server } = require("socket.io");
const { createClient } = require('redis');
const { createAdapter } = require('@socket.io/redis-adapter');
const crypto = require("crypto");
const bcrypt = require("bcrypt");

// For webpages
const app = express();
app.use(express.json());
const server = http.createServer(app);
const io = new Server(server, {pingTimeout: 20000});

// Controllers
const DukeChessController = require("./dukechess/js-backend/flow/Controller");
const ChessController = require("./chess/js-backend/flow/Controller");

// Serve pages
app.use("/dukechess", express.static(__dirname + "/dukechess"));
app.use("/chess", express.static(__dirname + "/chess"));
app.use("/global", express.static(__dirname + "/global"));

const db = require("./db/db");

// Redis
const REDIS_URL = process.env.REDIS_URL || "redis://127.0.0.1:6379";
const pubClient = createClient({ url: REDIS_URL });
const subClient = pubClient.duplicate();

// serverSideEmit alternative
const busPub = pubClient.duplicate();
const busSub = pubClient.duplicate();

// Global setup
const REDIS_GLOBAL_NS = "global";

const authKey = (u) => `${REDIS_GLOBAL_NS}:user:auth:${u}`;

const u2tKey = (u, game) => `${REDIS_GLOBAL_NS}:user:token:${u}:${game}`; // username -> token
const t2uKey = (t, game) => `${REDIS_GLOBAL_NS}:token:user:${t}:${game}`; // token -> username

// Setup for DukeChess
const REDIS_NS = "dc"; // namespace

const CH_MSG = `${REDIS_NS}:channel:msg`;
const CH_DIS = `${REDIS_NS}:channel:disconnect`;

const qKey = (game) => `${REDIS_NS}:queue:${game}`;

const u2sKey = (u) => `${REDIS_NS}:user:socket:${u}`; // username -> sid
const s2uKey = (sid) => `${REDIS_NS}:socket:user:${sid}`; // sid -> username

const s2gKey = (sid) => `${REDIS_NS}:socket:game:${sid}`; // sid -> gid
const s2pKey = (sid) => `${REDIS_NS}:socket:platform:${sid}`; // sid -> platform
const gOwnerKey = (gid) => `${REDIS_NS}:game:owner:${gid}`; // which node owns the controller
const gInfoKey = (gid) => `${REDIS_NS}:game:info:${gid}`;   // HSET gid -> {name, p1, p1Platform, p2, p2Platform}
const TTL = 30 * 60; // 30 minutes

function makeEmitter(io, name) {
  return {
    emitToSocket: (sid, event, payload) => {
        io.of(`/${name}`).to(sid).emit(event, payload);
    }
  };
}

// Maps
const controllers = new Map(); // gid -> controller

function getController(name, p1, p1Platform, p2, p2Platform, emitter) {
    switch (name) {
        case 'dukechess':
            return new DukeChessController(p1, p1Platform, p2, p2Platform, emitter);
        case 'chess':
            return new ChessController(p1, p2, emitter);
    }
}

// Random IDs
const SERVER_ID = crypto.randomBytes(6).toString("hex"); // unique id for each server (used to route to controller owner)

function newGameId(game) {
  return `${game}:${Date.now().toString(36)}:${Math.random().toString(36).slice(2, 10)}`; // 36: most compact alphanumeric representation
}

// POST /api/login
app.post("/api/login", async (req, res) => {
    const { username, password, name } = req.body || {};

    if (!username || !password || !name) {
        return res.status(400).json({ error: "missing info" });
    }

    try {
        const userResult = await db.query(
            "SELECT id, username, password_hash FROM users WHERE username = $1",
            [username]
        );

        const user = userResult.rows[0];

        // register
        if (!user) {
            const newHash = await bcrypt.hash(password, 12);

            await db.query(
                "INSERT INTO users (username, password_hash) VALUES ($1, $2)",
                [username, newHash]
            );

            return res.json({ status: "registered" });
        }

        const ok = await bcrypt.compare(password, user.password_hash);
        if (!ok) return res.status(401).json({ error: "wrong_password" });

        if (name === "dukechess" || name === "chess") {
            const existingU2S = await pubClient.get(u2sKey(username));
            if (existingU2S) {
                return res.status(403).json({ error: "already logged in" });
            }
            return res.json({ status: "ok" });
        } else {
            const token = crypto.randomBytes(24).toString("base64url");
            const old = await pubClient.get(u2tKey(username, name));
            if (old) await pubClient.del(t2uKey(old, name));

            await pubClient.setEx(u2tKey(username, name), TTL, token);
            await pubClient.setEx(t2uKey(token, name), TTL, username);

            return res.json({ status: "ok", token });
        }
    } catch (err) {
        console.error("login error:", err);
        return res.status(500).json({ error: "server_error" });
    }
});

async function match(name, sid, platform) {
    const queue = qKey(name);

    // save platform
    await pubClient.setEx(s2pKey(sid), TTL, platform);

    // remove from queue if already queued
    await pubClient.lRem(queue, 0, sid);

    // try to match
    const peerId = await pubClient.lPop(queue);

    // no peer found
    if (!peerId || peerId === sid) {
        await pubClient.rPush(queue, sid);

        io.of(`/${name}`).to(sid).emit("game", {
            connection: "false",
            message: "Wait for another player to join."
        });

        return;
    } 

    // found a peer
    const p1 = peerId;
    const p2 = sid;

    // check platforms
    const p1Platform = await pubClient.get(s2pKey(p1));
    const p2Platform = platform;

    // create a game
    const gid = newGameId(name);

    // store info
    await pubClient.hSet(gInfoKey(gid), {
        name, p1, p1Platform, p2, p2Platform
    });

    await pubClient.setEx(s2gKey(p1), TTL, gid);
    await pubClient.setEx(s2gKey(p2), TTL, gid);

    // set controller owner
    await pubClient.setEx(gOwnerKey(gid), TTL, SERVER_ID);

    // create a controller
    const emitter = makeEmitter(io, name);
    const controller = getController(name, p1, p1Platform, p2, p2Platform, emitter);
    controllers.set(gid, controller);

    io.of(`/${name}`).to([p1, p2]).emit("game", {
        connection: "true",
        message: "Connection established."
    });
}

function setupGame(name) {
    const gio = io.of(`/${name}`);

    gio.on("connection", (socket) => {
        socket.on('init', async function(payload) {
            const { username, password, platform } = payload;

            // authenticate
            if (!username || !password) return res.status(400).json({ error: "missing creds" });

            const userResult = await db.query(
                "SELECT password_hash FROM users WHERE username = $1",
                [username]
            );

            const user = userResult.rows[0];
            const hash = user?.password_hash;

            if (!hash || !(await bcrypt.compare(password, hash))) {
                socket.emit("game", {
                    connection: "false",
                    message: "Authentication failed."
                });
                return;
            }

            const existingU2S = await pubClient.get(u2sKey(username));
            if (existingU2S) {
                socket.emit("game", {
                    connection: "false",
                    message: "Already logged in."
                });
                return;
            }

            // write mappings
            await pubClient.setEx(u2sKey(username), TTL, socket.id);
            await pubClient.setEx(s2uKey(socket.id), TTL, username);

            //console.log('Platform received from ' + socket.id + ': ' + platform);
            await match(name, socket.id, platform);
        });

        socket.on("game", async function(msg) {
            const gid = await pubClient.get(s2gKey(socket.id));
            if (!gid) {
                socket.emit("game", {
                    connection: "false",
                    message: "Wait for another player to join."
                });
                return;
            }

            // forward to controller owner
            busPub.publish(CH_MSG, JSON.stringify({ gid, sid: socket.id, msg }));
        });

        socket.on('disconnect', async function(){
            //console.log('Disconnected from ' + socket.id);

            const gid = await pubClient.get(s2gKey(socket.id));
            if (gid) {
                busPub.publish(CH_DIS, JSON.stringify({ gid, sid: socket.id }));
                await pubClient.del(s2gKey(socket.id), s2pKey(socket.id));
            } else {
                // If they were only queued, remove them from any queue
                await pubClient.del(s2pKey(socket.id));
                await pubClient.lRem(qKey(name), 0, socket.id);
            }

            // remove user mappings
            const username = await pubClient.get(s2uKey(socket.id));

            await pubClient.del(u2sKey(username));
            await pubClient.del(s2uKey(socket.id));
        });
    });
}

// IIFE
(async function main() {
    try {
        await pubClient.connect();
        await subClient.connect();

        // remove all keys
        const iter = pubClient.scanIterator({ MATCH: `${REDIS_NS}:*`, COUNT: 1000 });
        const batch = [];
        for await (const key of iter) {
            if (key.length !== 0)batch.push(key);
            if (batch.length >= 500) {
                await pubClient.unlink(...batch); // non-blocking delete
                batch.length = 0;
            }
        }
        if (batch.length) await pubClient.unlink(...batch);
        console.log('Redis wipe ds done');

        // adapter
        io.adapter(createAdapter(pubClient, subClient));

        // serverSideEmit alternative
        await busPub.connect();
        await busSub.connect();

        await busSub.subscribe(CH_MSG, async (json) => {
            const { gid, sid, msg } = JSON.parse(json);

            const owner = await pubClient.get(gOwnerKey(gid));
            if (owner !== SERVER_ID) return; // not this server's responsibility

            const controller = controllers.get(gid);
            if (!controller) return;

            try {
                controller.execute(sid, msg);
            } catch (e) {
                console.error(`[${gid}] controller error:`, e);
            }
        });

        await busSub.subscribe(CH_DIS, async (json) => {
            const { gid, sid } = JSON.parse(json);

            const owner = await pubClient.get(gOwnerKey(gid));
            if (owner !== SERVER_ID) return;

            const info = await pubClient.hGetAll(gInfoKey(gid));
            if (!info || !info.p1 || !info.p2) return;

            const peerId = sid === info.p1 ? info.p2 : info.p1;
            const peerPlatform = sid === info.p1 ? info.p2Platform : info.p1Platform;
            const name = info.name;

            // rematch
            io.of(`/${name}`).to(peerId).emit("game", {
                connection: "false",
                message: "Wait for another player to join."
            });
            await pubClient.del(s2gKey(peerId));
            
            await match(name, peerId, peerPlatform);

            // delete old game controller
            controllers.delete(gid);
            await pubClient.del(gOwnerKey(gid));
            await pubClient.del(gInfoKey(gid));
        });

        // create games
        setupGame("dukechess");
        setupGame("chess");

        const PORT = Number(process.env.PORT || 80);
        server.listen(PORT, "127.0.0.1", () => {
            console.log(`Server listening on: ${PORT}`);
            console.log(`Redis adapter connected to ${REDIS_URL}`);
        });
    } catch (err) {
        console.error("Failed to start server:", err);
        process.exit(1);
    }
})();