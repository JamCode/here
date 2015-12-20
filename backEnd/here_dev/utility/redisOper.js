var redis = require('redis');
var redis_client = redis.createClient();
var config = require('../config/config');
var log = global.log;


exports.increaseUnreadCommentGoodCount = function (user_id) {
	// input unread good count to redis
	redis_client.hget(config.hashKey.commentGoodUnreadCount, user_id, function (err, reply) {
		if (err) {
			log.error(err, log.getFileNameAndLineNum(__filename));
			return;
		}

		if (reply == null) {
			reply = 1;
		} else {
			reply = parseInt(reply, 10) + 1;
		}

		log.debug('increase unread comment good count for ' + config.hashKey.commentGoodUnreadCount + ' ' + user_id + ' count:' + reply,
			log.getFileNameAndLineNum(__filename));

		redis_client.hset(config.hashKey.commentGoodUnreadCount, user_id, reply);
	});
};

exports.increaseUnreadGoodCount = function (user_id) {
	// input unread good count to redis
	redis_client.hget(config.hashKey.goodUnreadCount, user_id, function (err, reply) {
		if (err) {
			log.error(err, log.getFileNameAndLineNum(__filename));
			return;
		}

		if (reply == null) {
			reply = 1;
		} else {
			reply = parseInt(reply, 10) + 1;
		}

		log.debug('increase unread good count for ' + config.hashKey.goodUnreadCount + ' ' + user_id + ' count:' + reply,
			log.getFileNameAndLineNum(__filename));

		redis_client.hset(config.hashKey.goodUnreadCount, user_id, reply);
	});
};

exports.increaseUnreadCommentCount = function (user_id) {
	// input unread good count to redis
	redis_client.hget(config.hashKey.commentUnreadCount, user_id, function (err, reply) {
		if (err) {
			log.error(err, log.getFileNameAndLineNum(__filename));
			return;
		}

		if (reply == null) {
			reply = 1;
		} else {
			reply = parseInt(reply, 10) + 1;
		}

		log.debug('increase unread comment count for ' + config.hashKey.commentUnreadCount + ' ' + user_id,
			log.getFileNameAndLineNum(__filename));

		redis_client.hset(config.hashKey.commentUnreadCount, user_id, reply);
	});
};
