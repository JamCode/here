var express = require('express');
var cluster = require('cluster');
var sio = require('socket.io');
var port = 4000;
var num_processes = 2;
var net = require('net');
var sio_redis = require('socket.io-redis');


process.on('uncaughtException', function(err) {
    console.log('SOCKET SERVER Caught exception: ' + err.stack);
    // email.sendMail('SOCKET SERVER Caught exception: ' + err.stack);
});

if (cluster.isMaster) {

    var workers = [];
    // Helper function for spawning worker at index 'i'.
    var spawn = function(i) {
        workers[i] = cluster.fork();

        // Optional: Restart worker on exit
        workers[i].on('exit', function(worker, code, signal) {
            console.log('respawning worker', i);
            spawn(i);
        });
    };

    // Spawn workers.
    for (var i = 0; i < num_processes; i++) {
        spawn(i);
    }

    var worker_index = function(ip, len) {

        if (ip.length == undefined) {
            return 0;
        }

        var s = '';
        for (var i = 0, _len = ip.length; i < _len; i++) {
            if (ip[i] !== '.') {
                s += ip[i];
            }
        }

        return Number(s) % len;
    };

    // Create the outside facing server listening on our port.
    var server = net.createServer({
        pauseOnConnect: true
    }, function(connection) {
        // We received a connection and need to pass it to the appropriate
        // worker. Get the worker for this connection's source IP and pass
        // it the connection.
        var worker = workers[worker_index(connection.remoteAddress, num_processes)];
        worker.send('sticky-session:connection', connection);
    }).listen(port);



    cluster.on('listening', function(worker, address) {
        console.log("A socket worker with pid#" + worker.process.pid + " is now listening to:" + address.port);
    });

} else {

    var app = new express();


    var server = app.listen(0, 'localhost');
    var io = sio(server);

    io.adapter(sio_redis({
        host: 'localhost',
        port: 6279
    }));

    io.sockets.on('connection', function(socket) {
        console.log(process.pid + ' get connection ' + socket.id);
        socket.on('disconnect', function(msg) {
            console.log(msg);
        });

        socket.on('testMsg', function(msg, fn) {
            console.log(process.pid + ' get msg ' + msg);
        });
    });

    process.on('message', function(message, connection) {
        if (message !== 'sticky-session:connection') {
            return;
        }

        server.emit('connection', connection);
        connection.resume();
    });
}