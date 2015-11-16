var conn = require('./utility.js');
var config = require('../config/config');
var log = global.log;

exports.checkUserNameExist = function(reqBody, callback) {
	var sql = 'select *from user_base_info where user_name = ?';
	conn.executeSql(sql, [reqBody.user_name], callback);
};


exports.updateUserGender = function(reqBody, callback) {
	var sql = "update user_base_info set user_gender = ? where user_id = ?";
	conn.executeSql(sql, [reqBody.user_gender, reqBody.user_id], callback);
};

exports.updateBirthDay = function(reqBody, callback) {
	var sql = "update user_base_info set user_birth_day = ? where user_id = ?";
	conn.executeSql(sql, [reqBody.user_birth_day, reqBody.user_id], callback);

};


exports.submitFeedback = function(reqBody, callback) {

	var sql =
		'insert into feedback_info(fi_user_id, fi_feedback, fi_submit_timestamp)values(?,?,?)';
	var timestamp = Date.now() / 1000;

	conn.executeSql(sql, [reqBody.user_id, reqBody.feedback, timestamp], callback);
};

exports.findNearbyUser = function(locationInfo, callback) {

	var sql = 'select a.*, b.* from user_base_info a, user_location_info b ' +
		' where a.user_id = b.user_id and a.user_id != ? ' +
		' and  ((ABS(?-b.location_latitude)*111)<50 and  ABS(? - b.location_longitude)*COS(?)*111<50)' +
		' and unix_timestamp(now()) - b.refresh_timestamp<3600*24*15' +
		' and user_gender <> -1 ' +
		' and user_birth_day is not null ' +
		' order by b.refresh_timestamp desc limit 16';

	conn.executeSql(sql, [locationInfo.user_id, locationInfo.latitude,
		locationInfo.longitude, locationInfo.latitude
	], callback);
};

exports.getUserInfoByUserArray = function(userArrayString, callback) {
	var sql = 'select * from user_base_info where User_id in ' + userArrayString;
	conn.executeSqlString(sql, callback);
};

exports.updateUserBackgroundImage = function(user_id, url, callback) {
	var sql =
		'update user_base_info set user_background_image_url = ? where user_id = ?';
	conn.executeSql(sql, [url, user_id], callback);
};

exports.checkPhoneNum = function(userPhone, callback) {
	var sql = 'select user_phone from user_base_info where user_phone = ?';
	conn.executeSql(sql, [userPhone], callback);
};

exports.login = function(userPhone, password, callback) {
	var sql =
		'select * from user_base_info where user_phone = ? and user_password = ?';
	conn.executeSql(sql, [userPhone, password], callback);
};

exports.logout = function(user_id, callback) {
	var sql = 'update  user_base_info set is_logout = ? where user_id = ?';
	conn.executeSql(sql, [0, user_id], callback);
};

exports.updateLoginStatus = function(deviceToken, user_id) {
	var sql =
		'update  user_base_info set device_token = ?, is_logout = ? where user_id = ?';
	conn.executeSql(sql, [deviceToken, 0, user_id], null);
};

exports.register = function(userInfo, callback) {
	var sqlArray = [];
	var paraArray = [];

	log.debug(JSON.stringify(userInfo));

	sqlArray.push(
		'insert into user_base_info (user_id, user_phone, user_name, user_password, user_facethumbnail, user_face_image, user_gender, certificate_id, user_fans_count, user_follow_count, user_birth_day) values (?,?,?,?,?,?,?,?,?,?,?)'
	);
	sqlArray.push('insert into user_location_info (user_id) values (?)');
	paraArray.push([userInfo.id,
		userInfo.user_phone,
		userInfo.name,
		userInfo.password,
		userInfo.facethumbnail,
		userInfo.user_face_image,
		userInfo.user_gender,
		userInfo.certificate_id,
		userInfo.fans_count,
		userInfo.follow_count,
		userInfo.user_birth_day
	]);
	paraArray.push([userInfo.id]);

	conn.executeTwoStepTransaction(sqlArray, paraArray, callback);
};

exports.updateUserFace = function(userId, facethumbnail, imageUrl, callback) {
	var sql =
		'update user_base_info set user_facethumbnail = ?, user_face_image = ? where user_id = ?';
	conn.executeSql(sql, [facethumbnail, imageUrl, userId], callback);
};

exports.getFacethumbnail = function(userId, callback) {
	var sql = 'select user_facethumbnail from user_base_info where User_id = ?';
	conn.executeSql(sql, [userId], callback);
};

exports.getCertificateCode = function(userPhone, callback) {
	var sql =
		'select *from confirm_phone where user_phone = ? order by time_stamp desc limit 1';
	conn.executeSql(sql, [userPhone], callback);
};

exports.certificateCode = function(userPhone, certificateCode, timeStamp,
	callback) {
	var sql = 'select Time_stamp from confirm_phone where User_phone = ?';
	conn.executeSql(sql, [userPhone], function(flag, result) {
		if (flag) {
			if (result.length) {
				if (timeStamp - result[0].Time_stamp > config.number.threeMinute) {
					sql = 'insert into confirm_phone values(?,?,?)';
					conn.executeSql(sql, [userPhone, certificateCode, timeStamp], callback);
				} else {
					callback(true);
				}
			} else {
				sql = 'insert into confirm_phone values(?,?,?)';
				conn.executeSql(sql, [userPhone, certificateCode, timeStamp], callback);
			}
		} else {
			callback(false);
		}
	});
};

exports.getUserCertificateInfo = function(certificateId, callback) {
	var sql = 'select * from user_certificate_info where Certificate_id = ?';
	conn.executeSql(sql, [certificateId], callback);
};

// add by wanghan 20141007
// insert image url to user_image_info
exports.insertUserImageInfo = function(userId, userImageURL, timeStamp,
	callback) {
	var sql =
		'insert into user_image_info (user_id, user_image_url, time_stamp) values (?,?,?)';
	conn.executeSql(sql, [userId, userImageURL, timeStamp], callback);
};
// end by wanghan insert image url to user_image_info

// add by wanghan 20141007 for get user image
exports.getUserImage = function(userId, timestamp, count, callback) {
	var sql =
		'select * from image_url_v a where a.user_id = ? and a.timestamp<? order by timestamp desc limit ?';
	conn.executeSql(sql, [userId, timestamp, count], callback);
};

// end by wanghan for get user image

exports.getUserDetail = function(userId, callback) {
	var sql = 'select a.*,b.* from user_base_info a, user_location_info b where' +
		' a.user_id = b.user_id ' +
		' and a.user_id = ?';
	conn.executeSql(sql, [userId], callback);
};

// add by wanghan 20141008 for delete user image
exports.deleteUserImage = function(userId, userImageUrl, callback) {
	var sql =
		'delete from user_image_info where user_id= ? and user_image_url = ?';
	conn.executeSql(sql, [userId, userImageUrl], callback);
};
// end by wanghan 20141008 for delete user image

// add by wanghan 2014009 for update user info
exports.updateUserInfo = function(userInfo, callback) {
	var sql =
		'update user_base_info set User_career = ?, User_company = ?, User_sign = ?, User_interest = ? where User_id = ?';
	conn.executeSql(sql, [userInfo.user_career, userInfo.user_company, userInfo.user_sign,
		userInfo.user_interest, userInfo.user_id
	], callback);
};
// end by wanghan 20141009 for update user info

exports.insertLocationInfo = function(userId, callback) {
	var sql = 'insert into user_location_info (User_id) values (?)';
	conn.executeSql(sql, [userId], callback);
};

exports.updateLocationInfo = function(locationInfo, callback) {
	locationInfo.timeStamp = Date.now() / 1000;

	var sql =
		'update user_location_info set location_latitude = ?, location_longitude = ?, refresh_timestamp = ? where user_id = ?';
	conn.executeSql(sql, [locationInfo.latitude, locationInfo.longitude,
		locationInfo.timeStamp, locationInfo.user_id
	], callback);
};

exports.getNearbyPersonToken = function(user_id, callback) {
	var sql =
		'select b.device_token from user_location_info a, user_base_info b where a.user_id<>? and a.user_id = b.user_id';
	conn.executeSql(sql, [user_id], callback);
};

exports.updateFaceImage = function(user_id, user_image_url, callback) {
	var sql =
		'update user_base_info set user_facethumbnail = ? where user_id = ?';
	conn.executeSql(sql, [user_image_url, user_id], callback);
};

exports.getTokenByUserId = function(user_id, callback) {
	var sql =
		'select a.*, b.* from user_base_info a, device_notify_count b where a.user_id = ? ' +
		' and a.device_token = b.device_token';
	conn.executeSql(sql, [user_id], callback);
};

exports.getMissedMsgRecord = function(user_id, callback) {
	var sql = 'select *from get_missed_msg_record a where a.user_id = ?';
	conn.executeSql(sql, [user_id], callback);
};

exports.insertMissedMsgRecord = function(user_id, callback) {
	var timestamp = Date.now() / 1000;
	var sql =
		'insert into get_missed_msg_record (user_id, last_timestamp) values(?, ?)';
	conn.executeSql(sql, [user_id, timestamp], callback);
};

exports.updateMissedMsgRecord = function(user_id, callback) {
	var timestamp = Date.now() / 1000;
	var sql =
		'update get_missed_msg_record set last_timestamp = ? where user_id = ?';
	conn.executeSql(sql, [timestamp, user_id], callback);
};

exports.getUnreadComments = function(user_id, timestamp, callback) {
	var sql = 'select a.*, b.*, c.* from content_comment_info a, ' +
		' content_base_info b, ' +
		' user_base_info c where ' +
		' a.comment_to_user_id = ? ' +
		' and a.comment_user_id = c.user_id and a.content_id = b.content_id ' +
		' and comment_timestamp<? order by comment_timestamp DESC limit 6 ';
	conn.executeSql(sql, [user_id, timestamp], callback);
};

exports.getUnreadGood = function(reqBody, callback) {
	var sql =
		'select a.*, b.*, c.* from good_base_info a, content_base_info b, user_base_info c ' +
		' where b.content_id = a.content_id and b.user_id = ? ' +
		' and a.user_id <> ?' +
		' and a.user_id = c.user_id ' +
		' and a.gbi_timestamp<? order by a.gbi_timestamp DESC limit 6';

	conn.executeSql(sql, [reqBody.user_id, reqBody.user_id, reqBody.timestamp],
		callback);
};

exports.insertVisitRecord = function(user_id, visit_user_id, callback) {
	var timestamp = Date.now() / 1000;
	var sql =
		'insert into visit_record(user_id, visit_user_id, visit_timestamp) ' +
		' values(?, ?, ?)';

	conn.executeSql(sql, [user_id, visit_user_id, timestamp], callback);
};

exports.updateVisitRecord = function(user_id, visit_user_id, callback) {
	var timestamp = Date.now() / 1000;
	var sql =
		'update visit_record set visit_timestamp = ? where user_id = ? and visit_user_id = ?';
	conn.executeSql(sql, [timestamp, user_id, visit_user_id], callback);
};

exports.getVisitRecord = function(user_id, visit_user_id, callback) {
	var sql =
		'select *from visit_record a where a.user_id = ? and a.visit_user_id = ? ';
	conn.executeSql(sql, [user_id, visit_user_id], callback);
};

exports.getAllVisitRecord = function(user_id, timestamp, callback) {
	var sql =
		'select a.*, b.user_facethumbnail, b.user_name from visit_record a, user_base_info b ' +
		' where a.user_id = ? and a.visit_timestamp<? ' +
		' and b.user_id = a.visit_user_id ' +
		' order by a.visit_timestamp desc limit 16';
	conn.executeSql(sql, [user_id, timestamp], callback);
};

exports.getUserTokenInfo = function(user_id, callback) {
	var sql = 'select *from user_token_v where user_id = ?';
	conn.executeSql(sql, [user_id], callback);
};

exports.getAllContentLocation = function(user_id, callback) {
	var sql =
		'select a.*, b.* from content_location_info a, content_base_info b ' +
		' where a.content_id = b.content_id and b.user_id = ?';
	conn.executeSql(sql, [user_id], callback);
};

exports.getMyContentByCity = function(user_id, city_desc, callback) {
	var sql =
		'select a.*, b.*, c.* from content_location_info a , content_base_info b, user_base_info c ' +
		' where a.content_id = b.content_id and b.user_id = c.user_id ' +
		' and a.city_desc = ?' +
		' and c.user_id = ? order by b.content_publish_timestamp desc';
	conn.executeSql(sql, [city_desc, user_id], callback);
};

exports.checkBlackList = function(user_id, counter_user_id, callback) {
	var sql =
		'select * from user_black_list where user_id = ? and counter_user_id = ?';
	conn.executeSql(sql, [user_id, counter_user_id], callback);
};

exports.insertBlackList = function(user_id, counter_user_id, callback) {
	var timestamp = Date.now() / 1000;
	var sql = 'insert into user_black_list(user_id, counter_user_id, timestamp) ' +
		' values(?,?,?)';
	conn.executeSql(sql, [user_id, counter_user_id, timestamp], callback);
};

exports.deleteBlackList = function(user_id, counter_user_id, callback) {
	var sql =
		'delete from user_black_list where user_id = ? and counter_user_id = ?';
	conn.executeSql(sql, [user_id, counter_user_id], callback);
};

exports.getBlackList = function(user_id, callback) {
	var sql = 'select a.*, b.* from user_black_list a, user_base_info b ' +
		' where a.user_id = ? and a.counter_user_id = b.user_id';
	conn.executeSql(sql, [user_id], callback);
};

exports.addToUserCollectList = function(user_id, content_id, callback) {
	var timestamp = Date.now() / 1000;
	var sql =
		'insert into user_collect_list(user_id, content_id, timestamp) values(?,?,?)';
	conn.executeSql(sql, [user_id, content_id, timestamp], callback);
};

exports.getUserCollectList = function(user_id, callback) {
	var sql =
		'select a.*, b.* , c.* from user_collect_list a, content_base_info b ,user_base_info c ' +
		' where a.user_id = ? and a.content_id = b.content_id ' +
		' and c.user_id = b.user_id ' +
		' order by a.timeStamp desc';
	conn.executeSql(sql, [user_id], callback);
};

exports.getLastVisitUser = function(user_id, callback) {
	var sql =
		'select a.*, b.user_facethumbnail from visit_record a, user_base_info b ' +
		' where a.user_id = ? and a.visit_user_id = b.user_id order by visit_timestamp desc limit 1';
	conn.executeSql(sql, [user_id], callback);
};

exports.getAllUserInfo = function(callback) {
	var sql = 'select *from user_base_info';
	conn.executeSql(sql, [], callback);
};

exports.updateDeviceToken = function(deviceInfo, callback) {
	var sql = 'update user_base_info set device_token = ? where user_id = ?';
	conn.executeSql(sql, [deviceInfo.device_token, deviceInfo.user_id], callback);
};

exports.getDeviceNotifyCount = function(device_token, callback) {
	var sql = 'select *from device_notify_count a where a.device_token = ?';
	conn.executeSql(sql, [device_token], callback);
};

exports.insertDeviceNotifyCount = function(device_token, count, callback) {
	var sql =
		'insert into device_notify_count (device_token, count) values(?, ?)';
	conn.executeSql(sql, [device_token, count], callback);
};

exports.updateDeviceNotifyCount = function(device_token, count, callback) {

	log.logPrint(config.logLevel.DEBUG, 'updateDeviceNotifyCount count ' + count);
	log.logPrint(config.logLevel.DEBUG, 'updateDeviceNotifyCount device_token ' +
		device_token);

	var sql = 'update device_notify_count set count = ? where device_token = ?';
	conn.executeSql(sql, [count, device_token], callback);
};
