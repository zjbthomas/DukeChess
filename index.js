const express = require("express");

// For webpages
const app = express();
var http = require('http').Server(app);
var io = require('socket.io')(http, {pingTimeout: 20000});

// Controllers
const DukeChessController = require("./dukechess/js-backend/flow/Controller");
const ChessController = require("./chess/js-backend/flow/Controller");

// Serve pages
app.use('/dukechess', express.static(__dirname + "/dukechess"));
app.use('/chess', express.static(__dirname + "/chess"));

// Ports
http.listen(80, function(){
    console.log('HTTP on 80');
});

// Connection pool
var pool = new Map();
var id_to_game_types = new Map();
var platforms = new Map();

function getController(name, id, firstPointPlatform, session, secondPointPlatform, socket) {
    switch (name) {
        case 'dukechess':
            return new DukeChessController(id, firstPointPlatform, session, secondPointPlatform, socket);
        case 'chess':
            return new ChessController(id, session, socket);
    }
}

function match(name, id, socket) {
    for (var [session, peer] of pool) {
        if (session != id && null == peer && id_to_game_types.get(session) == id_to_game_types.get(id)) {
            console.log('Match ' + id + ' and ' + session);

            firstPointPlatform = platforms.get(id)
            secondPointPlatform = platforms.get(session)
            
            var peers = getController(name, id, firstPointPlatform, session, secondPointPlatform, socket);
            pool.set(id, peers);
            pool.set(session, peers);

            if (id == socket.id) {
                socket.emit("game", {
                    connection: "true",
                    message: "Connection established."
                });
            } else {
                socket.to(id).emit("game", {
                    connection: "true",
                    message: "Connection established."
                });
            }
            
            socket.to(session).emit("game", {
                connection: "true",
                message: "Connection established."
            });

            peers.execute(id, {
                type: "start"
            });

            return true;
        }
    }
    return false;
}

function handleSocket(socket, name) {
    console.log('Connected from ' + socket.id);

    if (!pool.has(socket.id)) {
        pool.set(socket.id, null);
    }

    socket.on('platform', function(platform) {
        console.log('Platform received from ' + socket.id + ': ' + platform);
        platforms.set(socket.id, platform);
        id_to_game_types.set(socket.id, name);

        if (!match(name, socket.id, socket)) {
            socket.emit("game", {
                connection: "false",
                message: "Wait for another player to join."
            });
        }
    });

    socket.on('disconnect', function(){
        console.log('Disconnected from ' + socket.id);

        peers = pool.get(socket.id);
        pool.delete(socket.id);
        platforms.delete(socket.id);
        id_to_game_types.delete(socket.id);

        if (null != peers) {
            session = (peers.firstPoint == socket.id)? peers.secondPoint: peers.firstPoint;
            pool.set(session, null);
            // no need to update platforms here

            if (!match(name, session, socket)) {
                socket.to(session).emit("game", {
                    connection: "false",
                    message: "Wait for another player to join."
                });
            }
        }
    });

    socket.on("game", function(msg) {
        peers = pool.get(socket.id);

        if (null != peers) {
            peers.execute(socket.id, msg);
        } else {
            socket.emit("game", {
                connection: "false",
                message: "Wait for another player to join."
            });
        }
    });
}

io.of('/dukechess').on('connection', (socket) => handleSocket(socket, 'dukechess'));
io.of('/chess').on('connection', (socket) => handleSocket(socket, 'chess'));