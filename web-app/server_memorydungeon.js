const express = require("express");
const bcrypt = require("bcrypt");

const db = require("./db/db");

const NAME = "memorydungeon";

const REDIS_MD_NS = "md";

function readToken(req) {
  const h = req.get("authorization") || req.get("Authorization");
  if (h && h.startsWith("Bearer ")) return h.slice(7);
  return req.body?.token || req.query?.token || null;
}

async function auth(redis, token, u2tKey, t2uKey, TTL) {
    const username = await redis.get(t2uKey(token, NAME));
    if (!username) return null;

    // refresh
    await redis.expire(t2uKey(token, NAME), TTL);
    await redis.expire(u2tKey(username, NAME), TTL);
    return username;
}

function apiMemoryDungeon({ redis, u2tKey, t2uKey, TTL }) {
    if (!redis) throw new Error("Redis required");

    const router = express.Router();
    router.use(express.json());

    const saveKey = (u) => `${REDIS_MD_NS}:user:data:${u}`;

    // For Godot
    router.use('/', express.static(__dirname + "/MemoryDungeon"));
    router.get('/',function (req, res) {
        res.sendFile(__dirname + '/MemoryDungeon/MemoryDungeon.html');
    });

    // POST /save
    router.post("/save", async (req, res) => {
        try {
            const token = readToken(req);
            if (!token) return res.status(401).json({ error: "missing_token" });

            const username = await auth(redis, token, u2tKey, t2uKey, TTL);
            if (!username) return res.status(401).json({ error: "unauthorized" });

            const { save } = req.body || {};
            if (typeof save !== "object" || save === null) {
                return res.status(400).json({ error: "bad_request" });
            }

            const allowed = [
                "version", "best_level", "saved_level", "gold",
                "ai_forget_rate", "hero", "owned_k", "owned_sp"
            ];

            const toStore = {};
            for (const k of allowed) {
                if (k in save) toStore[k] = save[k];
            }

            await db.query(
                `
                INSERT INTO memorydungeon_saves (user_id, save_data, updated_at)
                VALUES (
                    (SELECT id FROM users WHERE username = $1),
                    $2::jsonb,
                    NOW()
                )
                ON CONFLICT (user_id)
                DO UPDATE SET
                    save_data = EXCLUDED.save_data,
                    updated_at = NOW()
                `,
                [username, JSON.stringify(toStore)]
            );

            res.json({ status: "saved" });
        } catch (e) {
            console.error(e);
            return res.status(500).json({ error: "server_error" });
        }
    });

    // GET /load
    router.get("/load", async (req, res) => {
        try {
            const token = readToken(req);
            if (!token) return res.status(401).json({ error: "missing_token" });

            const username = await auth(redis, token, u2tKey, t2uKey, TTL);
            if (!username) return res.status(401).json({ error: "unauthorized" });

            const result = await db.query(
                `
                SELECT m.save_data
                FROM memorydungeon_saves m
                JOIN users u ON u.id = m.user_id
                WHERE u.username = $1
                `,
                [username]
            );

            const row = result.rows[0];
            res.json({ save: row ? row.save_data : null });
        } catch (e) {
            console.error(e);
            return res.status(500).json({ error: "server_error" });
        }
    });

    return { base: '/' + NAME, router };
}

module.exports = { apiMemoryDungeon };