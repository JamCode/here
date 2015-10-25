var redis = require('redis');
var redis_client = redis.createClient();
var config = require('../config/config');
var log = global.log;



exports.increaseUnreadGoodCount = function(user_id) {
	//input unread good count to redis
	redis_client.hget(config.goodUnreadCount, user_id, function(err, reply) {


		if (err) {
			log.error(err, log.getFileNameAndLineNum(__filename));
			return;
		}

		if (reply === null) {
			reply = 1;
		} else {
			reply = parseInt(reply) + 1;
		}

		log.debug('increase unread good count for '+config.goodUnreadCount+" "+user_id+" count:"+reply, 
			log.getFileNameAndLineNum(__filename));

		redis_client.hset(config.goodUnreadCount, user_id, reply);
	});
}

exports.increaseUnreadCommentCount = function(user_id) {
	//input unread good count to redis
	redis_client.hget(config.commentUnreadCount, user_id, function(err, reply) {

		log.debug('increase unread comment count for '+user_id, log.getFileNameAndLineNum(__filename));

		if (err) {
			log.error(err, log.getFileNameAndLineNum(__filename));
			return;
		}

		if (reply === null) {
			reply = 1;
		} else {
			reply = parseInt(reply) + 1;
		}

		redis_client.hset(config.commentUnreadCount, user_id, reply);
	});
}

