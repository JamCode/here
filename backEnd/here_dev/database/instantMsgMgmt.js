var mysql = require('mysql');
var conn = require('./utility.js');
var config = require('../config/config');

var log = global.log;

var encryp = require('../utility/encryption.js');


//add by wanghan 20141121 for save private message
exports.insertPrivateMsg = function(from_id, to_id, msg_content, msg_id, msg_type, datapath, voice_time, msg_srno, callback){
	var timestamp = Date.now()/1000;
	var datetime = new Date();

	log.debug('enter insertPrivateMsg', log.getFileNameAndLineNum(__filename));

	msg_content = encryp.encode(msg_content);
	
	log.debug(msg_content, log.getFileNameAndLineNum(__filename));
	var sql = 'insert into private_message_info(msg_id, sender_user_id, receive_user_id, message_content, msg_type, datapath, voice_time, msg_srno, send_timestamp, datetime)'
	+'values(?,?,?,?,?,?,?,?,?,?)';
	conn.executeSql(sql, [msg_id, from_id, to_id, msg_content, msg_type, datapath ,voice_time, msg_srno, timestamp, datetime], callback);
}

//end by wanghan 20141121 for save private message


exports.getMsgByID = function(msg_id, callback){
	var sql = 'select a.*,b.*, c.* from private_message_info a, user_base_info b, device_notify_count c '
	+ ' where msg_id = ? '
	+ ' and a.receive_user_id = b.user_id '
	+ ' and b.device_token = c.device_token';
	conn.executeSql(sql, [msg_id], callback);
}

//add by wanghan 20141129 for get missed message
exports.getAllMissedMsg = function(user_id, last_msg_timestamp, callback){
	var sql = "select a.*, b.* from private_message_info a, user_base_info b "
	+" where receive_user_id = ? and send_timestamp>? and a.sender_user_id = b.user_id";
	conn.executeSql(sql, [user_id, last_msg_timestamp], callback);
}

//end by wanghan 20141129 for get missed message

exports.getMissedMsg = function(user_id, counter_id, last_msg_timestamp, callback){
	var sql = "select * from private_message_info where sender_user_id = ? and receive_user_id = ? and send_timestamp>? order by send_timestamp DESC";
	conn.executeSql(sql, [counter_id, user_id, last_msg_timestamp], callback);
}


//add by wanghan 20150224 for get pri msg friend list
exports.getPriMsgList = function(user_id, callback){
	//console.log(user_id);
	// var sql = "select x.* from user_base_info x where x.user_id in"
	// + "(select a.sender_user_id from private_message_info a where a.receive_user_id = ? group by sender_user_id"
	// + " union"
	// + " select b.receive_user_id from private_message_info b where b.sender_user_id = ? group by receive_user_id)";
	
	
	var sql = "select y.*, x.* "
		+" from private_message_info y, user_base_info x where"
		+" (y.sender_user_id, y.send_timestamp) in"
		+" (select a.sender_user_id, max(a.send_timestamp) as receiveTime from private_message_info a where a.receive_user_id = ? "
		+"	group by a.sender_user_id"
		+" )"
	    +" and y.receive_user_id = ?"
	    +" and x.user_id = y.sender_user_id"
	    +" union"
	    +" select y.*, x.* "
		+" from private_message_info y, user_base_info x where"
		+" (y.receive_user_id, y.send_timestamp) in"
		+" (select a.receive_user_id, max(a.send_timestamp) as sendeTime from private_message_info a where a.sender_user_id = ? "
		+" group by a.receive_user_id)"
	    +" and y.sender_user_id = ?"
	    +" and x.user_id = y.receive_user_id";
	conn.executeSql(sql, [user_id, user_id, user_id, user_id], callback);
}


//end by wanghan 20150224 for get pri msg friend list


// exports.getRecentMsg = function(user_id, counter_id, callback){
// 	var sql = "select *from private_message_info where (sender_user_id = ? and receive_user_id = ?)"
// 	+" or (sender_user_id = ? and receive_user_id = ?) order by send_timestamp DESC limit 6";

// 	conn.executeSql(sql, [user_id, counter_id, counter_id, user_id, timestamp], callback);
// }



exports.getPriMsg = function(user_id, counter_id, timestamp, callback){

	var sql = "select a.* from private_message_info a"
	+" where ((a.sender_user_id = ? and a.receive_user_id = ?) or (a.sender_user_id = ? and a.receive_user_id = ?))"
	+" and a.send_timestamp<? order by a.send_timestamp DESC limit 6";

	conn.executeSql(sql, [user_id, counter_id, counter_id, user_id, timestamp], callback);
}







