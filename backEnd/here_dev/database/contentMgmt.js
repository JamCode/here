var conn = require('./utility.js');
var log = global.log;



exports.increaseCommentGoodCount = function(reqbody, callback){
	var sql = "update content_comment_info set comment_good_count = comment_good_count+1 " +
	" where content_comment_id = ?";
	conn.executeSql(sql, [reqbody.content_comment_id], callback);
};


exports.insertReportContent = function (contentBody, callback) {
	var sql = 'update content_base_info set content_report = 1 where content_id = ?';
	conn.executeSql(sql, [contentBody.content_id], callback);
};

//  add by wanghan 20141129 for publish active message

exports.insertContent = function (contentBody, callback) {
	var sql = 'insert into content_base_info(' +
	' content_id,' +
	' user_id, ' +
	' content, ' +
	' content_publish_latitude,' +
	' content_publish_longitude,' +
	' content_publish_timestamp, ' +
	' content_publish_date, ' +
	' anonymous, ' +
	' content_image_url, ' +
	' address) ' +
	' values(?,?,?,?,?,?,?,?,?,?)';

	conn.executeSql(sql,
		[contentBody.content_id,
		contentBody.user_id,
		contentBody.content,
		contentBody.publish_latitude,
		contentBody.publish_longitude,
		contentBody.timestamp,
		new Date(),
		contentBody.anonymous,
		contentBody.content_image_url,
		contentBody.address], callback);

	if (contentBody.cityDesc != null && contentBody.cityDesc != '') {
		insertContentLocationInfo(contentBody.content_id,
			contentBody.publish_latitude, contentBody.publish_longitude,
			contentBody.cityDesc, null);
	}
};

// end by wanghan 20141129 for publish active message


exports.commentGood = function(reqbody, callback){
	var timestamp = Date.now() / 1000;
	var sql = "insert into comment_good_base_info(content_comment_id, user_id, cgbi_timestamp) "+
	" values(?, ?, ?)";
	conn.executeSql(sql, [reqbody.content_comment_id, reqbody.user_id, timestamp], callback);
};

exports.insertContentImage = function (contentImageBody, callback) {
	log.info(contentImageBody.content_id +
		',' + contentImageBody.image_url +
		',' + contentImageBody.image_compress_url,
		log.getFileNameAndLineNum(__filename));

	var sql = 'insert into content_image_info(content_id, image_url, image_compress_url) ' +
	' values("' + contentImageBody.content_id + '","' + contentImageBody.image_url + '","' +
	contentImageBody.image_compress_url + '")';

	conn.executeSqlString(sql,
		callback);
};

function insertContentLocationInfo (content_id, content_publish_latitude, content_publish_longitude, city_desc, callback) {

	var sql = 'insert into content_location_info(content_id, content_publish_latitude, content_publish_longitude, city_desc) ' +
	' values(?, ?, ?, ?)';
	conn.executeSql(sql, [content_id, content_publish_latitude, content_publish_longitude, city_desc], callback);
}

exports.getNearbyContent = function (reqBody, callback) {

	var sql = 'select a.*, b.*,c.image_url, c.image_compress_url from content_base_info a left join content_image_info c on a.content_id = c.content_id, user_base_info b ' +
	' where a.user_id = b.user_id ' +
	' and ((ABS(?-a.content_publish_latitude)*111)<100 and  ABS(? - a.content_publish_longitude)*COS(?)*111<100)' +
	' and content_publish_timestamp<? ' +
	' and content_report = 0' +
	' order by content_publish_timestamp DESC limit 8';

	conn.executeSql(sql, [reqBody.user_latitude, reqBody.user_longitude, reqBody.user_latitude, reqBody.last_timestamp], callback);
};

exports.getAllContentByUser = function (user_id, callback) {
	var sql = 'select a.*, b.*, c.* from content_base_info a left join content_image_info c on a.content_id = c.content_id, user_base_info b ' +
	' where a.user_id = ? ' +
	' and a.user_id = b.user_id ' +
	' and a.anonymous<>1' +
	' order by a.content_publish_timestamp DESC';
	conn.executeSql(sql, [user_id], callback);
};

exports.getHisContentByUser = function (user_id, last_timestamp, callback) {
	var sql = 'select a.*, b.*, c.* from content_base_info a left join content_image_info c on a.content_id = c.content_id, user_base_info b ' +
	' where a.user_id = ? ' +
	' and a.user_id = b.user_id ' +
	' and a.content_publish_timestamp<? ' +
	' and a.anonymous<>1' +
	' order by a.content_publish_timestamp DESC limit 8';
	conn.executeSql(sql, [user_id, last_timestamp], callback);
};

exports.getContentByUser = function (user_id, last_timestamp, anonymous, callback) {

	//  if (anonymous == true) {
	//  	var sql = 'select a.*, b.* from content_base_info a, user_base_info b '
	//  	 + ' where a.user_id = ? '
	//  	 + ' and a.user_id = b.user_id '
	//  	 + ' and a.content_publish_timestamp<? '
	//  	 + ' order by a.content_publish_timestamp DESC limit 8';
	//  	conn.executeSql(sql, [user_id, last_timestamp], callback);
	//  };else{
	var sql = 'select a.*, b.*, c.* from content_base_info a left join content_image_info c on a.content_id = c.content_id, user_base_info b ' +
	' where a.user_id = ? ' +
	' and a.user_id = b.user_id ' +
	' and a.content_publish_timestamp<? ' +
	' and a.anonymous<>1' +
	' order by a.content_publish_timestamp DESC limit 8';
	conn.executeSql(sql, [user_id, last_timestamp], callback);
	// };

};

exports.getContentBaseInfo = function (content_id, callback) {
	var sql = 'select a.*,b.*, d.* from content_base_info a left join content_image_info d on a.content_id = d.content_id, user_base_info b where a.content_id = ? ' +
	' and a.user_id = b.user_id';
	conn.executeSql(sql, [content_id], callback);
};

exports.getContentCommentsList = function (content_id, callback) {
	var sql = 'select a.*, b.*, c.user_id as to_user_id, c.user_name as to_user_name from content_comment_info a, user_base_info b, user_base_info c ' +
	' where a.content_id = ? ' +
	' and a.comment_user_id = b.user_id ' +
	' and a.comment_to_user_id = c.user_id order by a.comment_timestamp DESC';
	conn.executeSql(sql, [content_id], callback);
};

// add by wanghan 20141218 for add comments for an active
exports.addCommentToContent = function (reqBody, callback) {
	var timestamp = Date.now() / 1000;
	var content_comment_id = conn.sha1Cryp(reqBody.content_id + reqBody.user_id + reqBody.to_user_id + timestamp);
	var sql = 'insert into content_comment_info ' +
	'(content_comment_id, content_id, comment_user_id, comment_to_user_id, ' +
	' comment_content, comment_timestamp) values(?,?,?,?,?,?)';
	conn.executeSql(sql, [content_comment_id, reqBody.content_id,
		reqBody.user_id, reqBody.to_user_id, reqBody.comment, timestamp], callback);

	sql = 'update content_base_info set content_comment_count = content_comment_count + 1 where content_id = ?';
	conn.executeSql(sql, [reqBody.content_id], null);

};

// add by wanghan 20141219 for add see count

exports.addSeeCount = function (content_id, callback) {
	var sql = 'update content_base_info set content_see_count = content_see_count + 1 where content_id = ?';
	conn.executeSql(sql, [content_id], callback);
};

// end by wanghan 20141219 for add see count

exports.checkGoodCount = function (content_id, user_id, callback) {
	var sql = 'select * from content_base_info where content_id = ? and user_id = ?';
	conn.executeSql(sql, [content_id, user_id], callback);
};

exports.addGoodCount = function (content_id, user_id, callback) {
	var sql = 'select * from good_base_info a where a.user_id=? and a.content_id=?';
	conn.executeSql(sql, [user_id, content_id], callback);
};

exports.updateGoodCount = function (content_id) {
	var sql = 'update content_base_info set content_good_count = content_good_count + 1 where content_id = ?';
	conn.executeSql(sql, [content_id], null);
	sql = 'update user_base_info set good_count = good_count + 1 where user_id in ' +
	' (select user_id from content_base_info where content_id = ?)';
	conn.executeSql(sql, [content_id], null);
};

exports.insertGoodInfo = function (content_id, user_id) {
	var timestamp = Date.now() / 1000;
	var sql = 'insert into good_base_info(user_id, content_id, gbi_timestamp) values(?, ?, ?)';
	conn.executeSql(sql, [user_id, content_id, timestamp], null);
};

// add by wanghan 20141231 for add get popular content
exports.getPopularContent = function (reqBody, callback) {

	var timestamp = Date.now() / 1000;
	var sql = 'select a.*, b.*, c.* from content_base_info a left join content_image_info c on a.content_id = c.content_id, user_base_info b ' +
	' where a.user_id = b.user_id ' +
	' and content_publish_timestamp>?' +
	' order by content_good_count*1 + content_comment_count*3 + content_see_count*2 DESC limit 16';

	conn.executeSql(sql, [timestamp - 4 * 3600 * 24], callback);
};

exports.getContentImage = function(content_id, callback){
	var sql = "select *from content_image_info where content_id = ?";
	conn.executeSql(sql, [content_id], callback);
};

exports.deleteContentImage = function(content_id, callback){
	var sql = "delete from content_image_info where content_id = ?";
	conn.executeSql(sql, [content_id], callback);
};

exports.deleteContent = function (content_id, callback) {
	var sql = 'delete from content_base_info where ' +
	' content_id = ?';
	conn.executeSql(sql, [content_id], callback);

	sql = 'delete from content_comment_info where ' +
	' content_id = ?';
	conn.executeSql(sql, [content_id]);

};

exports.getAllContentImage = function (callback) {
	var sql = 'select *from content_image_info';
	conn.executeSql(sql, [], callback);
};

exports.getfollowContent = function(reqbody, callback){
	var sql = 'select a.*, b.*, c.* from content_base_info a left join content_image_info c on a.content_id = c.content_id, user_base_info b ' +
	' where a.user_id = b.user_id ' +
	' and a.user_id in ' +
	'(select followed_user_id from user_follow_base_info where user_id = ?) ' +
	' and a.content_publish_timestamp < ? ' +
	' and a.content_report = 0' +
	' and a.anonymous <> 1 ' +
	' order by a.content_publish_timestamp desc limit 8';
	conn.executeSql(sql, [reqbody.user_id, reqbody.timestamp], callback);
};
