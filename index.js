const express = require("express");
const app = express();
var http = require('http').Server(app);
var io = require('socket.io')(http);

const DukeChessController = require("./dukechess/js-backend/flow/Controller");
const ChessController = require("./chess/js-backend/flow/Controller");

app.use('/dukechess', express.static(__dirname + "/dukechess"));
app.use('/chess', express.static(__dirname + "/chess"));

http.listen(80, function(){
    console.log('HTTP on 80');
});

var pool = new Map();

function getController(name, id, session, socket) {
    switch (name) {
        case 'dukechess':
            return new DukeChessController(id, session, socket);
        case 'chess':
            return new ChessController(id, session, socket);
    }
}

function match(name, id, socket) {
    for (var [session, peer] of pool) {
        if (session != id && null == peer) {
            var peers = getController(name, id, session, socket);
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
    if (!pool.has(socket.id)) {
        pool.set(socket.id, null);

        if (!match(name, socket.id, socket)) {
            socket.emit("game", {
                connection: "false",
                message: "Wait for another player to join."
            });
        }
    }

    socket.on('disconnect', function(){
        peers = pool.get(socket.id);
        pool.delete(socket.id);

        if (null != peers) {
            session = (peers.firstPoint == socket.id)? peers.secondPoint: peers.firstPoint;
            pool.set(session, null);

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
    })
}

io.of('/dukechess').on('connection', (socket) => handleSocket(socket, 'dukechess'));
io.of('/chess').on('connection', (socket) => handleSocket(socket, 'chess'));