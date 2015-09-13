

function loginSocket(){
	var id = $("#id").value();
	console.log(id);
	var socket = io.connect('111.206.45.12:30114');
	socket.on('connect', function(data){
		console.log('connect success');
		socket.emit('register',{userID:id});//向服务器发送数据，实现双向数据传输
	});
}
