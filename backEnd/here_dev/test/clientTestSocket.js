var socketArr = new Array();

// var pathArr = require.paths();

// pathArr.forEach(function(ele){
// 	console(ele);
// });
var connectCount;
var port;
var sendCount;


process.argv.forEach(function(val, index, array) {
	if (index == 2) {
		port = val;
	}
	if (index == 3) {
		connectCount = val;
	}
	if (index == 4) {
		sendCount = val;
	}
	console.log(index + ': ' + val);
});


for (var i = 0; i < connectCount; ++i) {
	f2(i);
}


setInterval(function() {
	for (var i = 0; i < sendCount / 10; ++i) {
		var index = Math.floor(Math.random() * (connectCount - 1));
		if (socketArr[index] != -1) {
			socketArr[index].emit('testMsg', 'it a test send by ' + socketArr[i].id);
		} else {
			console.log('socket.id is invalid');
		}
	}
}, 100);

function f2(i) {
	socketArr[i] = -1;
	var socket = require('socket.io-client')('http://112.74.102.178:' + port, {
		'force new connection': true
	});

	socket.on('connect', function() {
		console.log('get connect ' + socket.id);
		//console.log(err);
		socketArr[i] = socket;
	});

	socket.on('connect_error', function(err) {
		console.log('connect_error ' + err);
		socketArr[i] = -1;
	});

	socket.on('disconnect', function() {
		console.log('disconnect');
		socketArr[i] = -1;
	});

	//console.log('client connect to server');

	//socketArr[i] = socket;
}