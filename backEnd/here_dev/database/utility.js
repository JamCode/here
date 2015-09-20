var log = global.log;

var mysql = require('mysql');
var config = require('../config/config');
var global_config = require('../config/env_config');
var crypto = require('crypto'); 

global_config.mysql_dev = decodeDBStr(global_config.mysql_dev);

var pool = mysql.createPool(global_config.mysql_dev);
var domain = require('domain');
var domainObj = domain.create();
var path = require('path');


function decodeDBStr(mysqlDev){

	var decipher = crypto.createDecipher('aes-256-cbc', '123');
    var decrypted = decipher.update(mysqlDev.user, 'hex', 'binary');
    decrypted += decipher.final('binary');
    mysqlDev.user = decrypted;

    
   	decipher = crypto.createDecipher('aes-256-cbc', '123');
    decrypted = decipher.update(mysqlDev.password, 'hex', 'binary');
    decrypted += decipher.final('binary');
    mysqlDev.password = decrypted;
    log.debug(mysqlDev.user+","+mysqlDev.password, log.getFileNameAndLineNum(__filename));
    return mysqlDev;
}

exports.sha1Cryp = function(str){
	var shasum = crypto.createHash('sha1'); 
	shasum.update(str); 
	return shasum.digest('hex');
}

exports.executeSql = function(sql, para, callback) {
	pool.getConnection(function(err, conn){
		if (err) {
			log.error(err, log.getFileNameAndLineNum(__filename));
			if(typeof callback === 'function'){
				callback(false, err);
			}
		}
		//modify by wanghan 20141007
		else{
			conn.query(sql, para, function(err, result){

				if(err){
					log.error(sql + " " + err, log.getFileNameAndLineNum(__filename));
					if(typeof callback === 'function'){
						callback(false, err);
					}
				}else{
					if (typeof callback === 'function') callback(true, result);
				}
				conn.release();
			});			
		}
	});
}

exports.executeSqlString = function(sql, callback) {
	pool.getConnection(function(err, conn){
		if (err){
			log.error(err, log.getFileNameAndLineNum(__filename));
			if(typeof callback === 'function'){
				callback(false, err);
			}
		}else{
			conn.query(sql, function(err, result){
				if (err) {
					log.error(sql + " " + err, log.getFileNameAndLineNum(__filename));
					if(typeof callback === 'function'){
						callback(false, err);
					}

				}else{
					if (callback && typeof callback === 'function') callback(true, result);
				}
			});
		}
	});
}

exports.executeTwoStepTransaction = function(sqlArray, paraArray, callback){
	pool.getConnection(function(err, conn){
		if (err){
			callback(false, err);
		}else {
			var queues = require('mysql-queues');
			const DEBUG = true;
			queues(conn, DEBUG);
			var trans = conn.startTransaction();
			trans.query(sqlArray[0], paraArray[0], function(err, result) {
			    if(err) {
			    	trans.rollback();
			    	callback(true);
			    }
			    else
			        trans.query(sqlArray[1], paraArray[1], function(err) {
			            if(err){
			            	trans.rollback();
			            	callback(true);
			            }
			            else{
			            	trans.commit();
			            	callback(true, result);
			            }
			        });
			});
			trans.execute();
		}
	});
}



exports.pushMsgToUsers = function(userToken, msg){
	if(userToken === undefined|| userToken === ''){
		log.warn("userToken is null", log.getFileNameAndLineNum(__filename));
		return;
	}

	log.debug(path.join(__dirname, 'heretest.pem'), log.getFileNameAndLineNum(__filename));
	log.debug(path.join(__dirname, 'heretestkey.pem'), log.getFileNameAndLineNum(__filename));
	log.debug(msg, log.getFileNameAndLineNum(__filename));

	var apns = require('apn');
	var options = {
		cert: path.join(__dirname, 'heretest.pem'),
		key: path.join(__dirname, 'heretestkey.pem'),
		passphrase: '8888',
		/* Key file path */
		gateway: 'gateway.push.apple.com',
		/* gateway address */
		port: 2195,
		/* gateway port */
		errorCallback: apnErrorHappened,
		/* Callback when error occurs function(err,notification) */
	}
	
	domainObj.run(function(){
		var apnsConnection = new apns.Connection(options);
		var token = userToken;
		var myDevice = new apns.Device(token);
		var note = new apns.Notification();
		note.expiry = Math.floor(Date.now() / 1000) + 3600; // Expires 1 hour from now.
		note.badge = msg.badge+1;
		note.alert = msg.content;
		note.payload = msg;
		note.device = myDevice;
		apnsConnection.sendNotification(note);
		log.debug("send notification to "+userToken, log.getFileNameAndLineNum(__filename));
	});
}



// exports.apnPushTo = function(user_id, msg, badgeCount){

// }



function apnErrorHappened(err, notification) {
	// var Errors = {
// 	"noErrorsEncountered": 0,
// 	"processingError": 1,
// 	"missingDeviceToken": 2,
// 	"missingTopic": 3,
// 	"missingPayload": 4,
// 	"invalidTokenSize": 5,
// 	"invalidTopicSize": 6,
// 	"invalidPayloadSize": 7,
// 	"invalidToken": 8,
// 	"apnsShutdown": 10,
// 	"none": 255,
// 	"retryLimitExceeded": 512,
// 	"moduleInitialisationFailed": 513,
// 	"connectionRetryLimitExceeded": 514, // When a connection is unable to be established. Usually because of a network / SSL error this will be emitted
// 	"connectionTerminated": 515
// };
	if (err == 8) {
		//
		log.warn("err code:" + err + " "+JSON.stringify(notification), log.getFileNameAndLineNum(__filename));
	}else{
		log.error("err code:" + err +" "+ JSON.stringify(notification), log.getFileNameAndLineNum(__filename));
	}
}

domainObj.on('error',function(err){
	log.error(err, log.getFileNameAndLineNum(__filename));
});




