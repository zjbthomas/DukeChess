const express = require("express");
const app = express();
var http = require('http').Server(app);
var io = require('socket.io')(http);

const Controller = require("./public/js-backend/flow/Controller");

app.use(express.static("public"));

http.listen(80, function(){
    console.log('HTTP on 80');
});

var pool = new Map();

function match(id, socket) {
    for (var [session, peer] of pool) {
        if (session != id && null == peer) {
            var peers = new Controller(id, session, socket);
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

io.on('connection', function(socket){
    if (!pool.has(socket.id)) {
        pool.set(socket.id, null);

        if (!match(socket.id, socket)) {
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

            if (!match(session, socket)) {
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
  });
