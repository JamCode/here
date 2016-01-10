var express = require('express');
var formidable = require('formidable');
var contentMgmt = require('../database/contentMgmt.js');
var userMgmt = require('../database/userMgmt.js');

var config = require('../config/config');

var global_config = global.global_config;

var router = express.Router();
var path = require('path');
var conn = require('../database/utility.js');
var log = global.log;
var routeFunc = require('./routeFunc.js');
var imageOper = require('../utility/imageOper');
var os = require('os');
var networkInterface = os.networkInterfaces();

var imageHomeUrl = 'https://' + networkInterface.eth1[0].address + ':' +
	global_config.httpServerInfo.listen_port + config.imageInfo.url;

log.debug(imageHomeUrl, log.getFileNameAndLineNum(__filename));

var redisOper = require('../utility/redisOper');


router.post('/commentGood', function(req, res) {
	contentMgmt.commentGood(req.body, function(flag, result){
		var returnData = {};
		if(flag){
			returnData.code = config.returnCode.SUCCESS;
			contentMgmt.increaseCommentGoodCount(req.body, function(flag, result){
				if(!flag){
					log.error(result, log.getFileNameAndLineNum(__filename), req.body.sq);
				}
			});

			//推送到前端
			log.debug(req.body.comment_user_id, log.getFileNameAndLineNum(__filename), req.body.sq);
			apnToUser(req.body.comment_user_id, req.body.user_name + '赞了你的评论');
			redisOper.increaseUnreadCommentGoodCount(req.body.comment_user_id);

		}else{
			log.debug(result.code, log.getFileNameAndLineNum(__filename), req.body.sq);
			if(result.code === 'ER_DUP_ENTRY'){
				returnData.code = config.returnCode.COMMENT_GOOD_EXIST;
			}else{
				returnData.code = config.returnCode.ERROR;
				log.error(result, log.getFileNameAndLineNum(__filename), req.body.sq);
			}
		}
		res.send(returnData);
	});
});

router.post('/getAllContentLocation', function(req, res) {
	// log.logPrint(config.logLevel.INFO, JSON.stringify(req.body));
	contentMgmt.getAllContentLocation(req.body.user_id, function(flag, result) {
		routeFunc.feedBack(flag, result, res);
	});
});

router.post('/getMyContentByCity', function(req, res) {
	// log.logPrint(config.logLevel.INFO, JSON.stringify(req.body));
	contentMgmt.getMyContentByCity(req.body.user_id, req.body.city_desc,
		function(flag, result) {
			packageContentArray(flag, result, res);
		});
});

// add by wanghan 20141129 for publish active
router.post('/publishContent', function(req, res) {

	// log.info(JSON.stringify(req.body), log.getFileNameAndLineNum(__filename));

	if (req.body.imageCount === 0) {
		var timestamp = Date.now() / 1000;
		var content_id = conn.sha1Cryp(req.body.user_id + timestamp);

		req.body.content_id = content_id;
		req.body.timestamp = timestamp;

		// routeFunc.feedBack(true, 'ok', res);
		contentMgmt.insertContent(req.body, function(flag, result) {
			log.debug(JSON.stringify(result), log.getFileNameAndLineNum(__filename));
			routeFunc.feedBack(flag, result, res);
		});
	} else {
		log.debug('has image', log.getFileNameAndLineNum(__filename));

		var form = new formidable.IncomingForm();
		form.parse(req, function(err, fields, files) {
			if (err) {
				routeFunc.feedBack(false, null, res);
				return;
			}

			req.body = fields;
			log.info(JSON.stringify(req.body), log.getFileNameAndLineNum(__filename));

			var timestamp = Date.now() / 1000;
			log.debug(req.body.user_id + timestamp, log.getFileNameAndLineNum(
				__filename));

			var content_id = conn.sha1Cryp(req.body.user_id + timestamp);
			req.body.content_id = content_id;
			req.body.timestamp = timestamp;
			log.debug(req.body.imageCount, log.getFileNameAndLineNum(__filename));
			for (var i = 0; i < req.body.imageCount; ++i) {
				var fileName = files['content_image_' + i].path + Date.now();
				log.debug(fileName, log.getFileNameAndLineNum(__filename));
				fileName = conn.sha1Cryp(fileName);

				var url = imageHomeUrl + fileName;
				var compressUrl = imageHomeUrl + fileName + '_compress';

				if (i === 0) {
					req.body.content_image_url = compressUrl;
				}

				var contentImageBody = {
					content_id: req.body.content_id,
					image_url: url,
					image_compress_url: compressUrl
				};

				contentMgmt.insertContentImage(contentImageBody, function(flag, result) {
					if (!flag) {
						log.error(result, log.getFileNameAndLineNum(__filename));
					}
				});

				var fullFileName = path.join(global_config.env.homedir, config.imageInfo
					.imageRootDir, fileName);
				var fullFileNameCompress = fullFileName + '_compress';

				imageOper.updateImage(files['content_image_' + i].path, fullFileName,
					fullFileNameCompress, {
						width: 66 * 4,
						height: 66 * 4
					});
			}

			contentMgmt.insertContent(req.body, function(flag, result) {
				routeFunc.feedBack(flag, result, res);
			});

			// updateImage(files.content_image.path, fullFileName, fullFileNameCompress);
			// updateImage(files.content_image.path, path.join(global_config.env.homedir, config.imageInfo.imageRootDir, fileName+'_compress'), 4);

		});
	}
});

function packageContentArray(flag, result, res) {
	var statusCode;
	var returnData = {
		contents: {},
		code: 0
	};
	if (flag) {
		statusCode = config.returnCode.SUCCESS;
		var contentInfoDic = {};
		var activeInfo = null;
		result.forEach(function(item) {
			if (contentInfoDic[item.content_id] === undefined) {
				activeInfo = {
					content_id: item.content_id,
					user_id: item.user_id,
					content: item.content,
					content_publish_latitude: item.content_publish_latitude,
					content_publish_longitude: item.content_publish_longitude,
					content_see_count: item.content_see_count,
					content_good_count: item.content_good_count,
					content_comment_count: item.content_comment_count,
					content_publish_timestamp: item.content_publish_timestamp,
					user_facethumbnail: item.user_facethumbnail,
					user_face_image: item.user_face_image,
					user_name: item.user_name,
					user_age: item.user_age,
					user_birth_day: item.user_birth_day,
					user_gender: item.user_gender,
					anonymous: item.anonymous,
					content_image_url: item.content_image_url,
					address: item.address,
					content_image_url_array: [],
					content_image_compress_url_array: []
				};
				if (item.image_url !== undefined) {
					activeInfo.content_image_url_array.push(item.image_url);
					activeInfo.content_image_compress_url_array.push(item.image_compress_url);
				}
				// contentInfoDic.push(item.content_id, activeInfo);
				contentInfoDic[item.content_id] = activeInfo;
			} else {
				activeInfo = contentInfoDic[item.content_id];
				if (item.image_url !== undefined) {
					activeInfo.content_image_url_array.push(item.image_url);
					activeInfo.content_image_compress_url_array.push(item.image_compress_url);
				}
				// contentInfoDic.push(item.content_id, activeInfo);
				contentInfoDic[item.content_id] = activeInfo;
			}
		});

		returnData.contents = contentInfoDic;
	} else {
		log.logPrint(config.logLevel.ERROR, 'getContent error with detail:' + result);
		statusCode = config.returnCode.ERROR;
	}

	returnData.code = statusCode;
	res.send(returnData);
}

// add by wanghan 20141226 for get nearby content
router.post('/getNearbyContent', function(req, res) {
	contentMgmt.getNearbyContent(req.body, function(flag, result) {
		packageContentArray(flag, result, res);
	});
});

router.post('/getContentByUser', function(req, res) {
	var anonymous;
	if (req.body.user_id === req.body.my_user_id) {
		log.logPrint(config.logLevel.DEBUG, 'anonymous is true');
		anonymous = true;
	} else {
		log.logPrint(config.logLevel.DEBUG, 'anonymous is false');
		anonymous = false;
	}

	contentMgmt.getContentByUser(req.body.user_id, req.body.last_timestamp,
		anonymous,
		function(flag, result) {
			packageContentArray(flag, result, res);
		});
});

router.post('/getHisContentByUser', function(req, res) {

	contentMgmt.getHisContentByUser(req.body.user_id, req.body.last_timestamp,
		function(flag, result) {
			packageContentArray(flag, result, res);
		});
});

router.post('/getAllContentByUser', function(req, res) {
	contentMgmt.getAllContentByUser(req.body.user_id, function(flag, result) {
		routeFunc.feedBack(flag, result, res);
	});
});

router.post('/getContentBaseInfo', function(req, res) {
	contentMgmt.getContentBaseInfo(req.body.content_id, function(flag, result) {
		packageContentArray(flag, result, res);
	});

});

// add by wanghan 20141231 for get popular content
router.post('/getPopularContent', function(req, res) {
	contentMgmt.getPopularContent(req.body, function(flag, result) {
		packageContentArray(flag, result, res);
	});
});

router.post('/getContentCommentsList', function(req, res) {

	contentMgmt.getContentCommentsList(req.body.content_id, function(flag,
		result) {
		var returnData = {
			comments: []
		};
		if (flag && result) {
			result.forEach(function(item) {
				var commentInfo = {
					comment_content: item.comment_content,

					user_id: item.comment_user_id,
					user_name: item.user_name,
					user_facethumbnail: item.user_facethumbnail,

					content_comment_id: item.content_comment_id,
					content_id: item.content_id,

					comment_to_user_id: item.comment_to_user_id,
					to_user_name: item.to_user_name,

					comment_timestamp: item.comment_timestamp,
					to_content: item.to_content,
					comment_good_count: item.comment_good_count
				};
				returnData.comments.push(commentInfo);
			});
			returnData.code = config.returnCode.GET_COMMENT_LIST;
		} else {
			returnData.code = config.returnCode.ERROR;
			log.logPrint(config.logLevel.ERROR, JSON.stringify(req.body));
		}
		res.send(returnData);
	});
});

router.post('/addSeeCount', function(req, res) {
	contentMgmt.addSeeCount(req.body.content_id, function(flag, result) {
		routeFunc.feedBack(flag, result, res);
	});
});

router.post('/addGoodCount', function(req, res) {
	// update to database
	// update to redis
	// push msg to user

	contentMgmt.addGoodCount(req.body.content_id, req.body.user_id, function(
		flag, result) {
		if (flag && result) {
			// cannot click good for one content mutiple time
			log.debug('before updateGoodCount and insertGoodInfo', log.getFileNameAndLineNum(
				__filename));
			if (result.length === 0) {

				log.debug('updateGoodCount and insertGoodInfo', log.getFileNameAndLineNum(
					__filename));
				contentMgmt.updateGoodCount(req.body.content_id);
				contentMgmt.insertGoodInfo(req.body.content_id, req.body.user_id);

				if (req.body.content_user_id !== req.body.user_id) {
					log.debug(req.body.content_user_id + ', ' + req.body.user_id, log.getFileNameAndLineNum(
						__filename));
					apnToUser(req.body.content_user_id, req.body.user_name + '赞了你的状态');
					// update redis
					redisOper.increaseUnreadGoodCount(req.body.content_user_id);
				}

			} else {
				log.debug('already in good info', log.getFileNameAndLineNum(__filename));
			}
		} else {
			log.debug(result, log.getFileNameAndLineNum(__filename));
		}
		routeFunc.feedBack(flag, result, res);
	});
});

function apnToUser(user_id, content) {
	// apn push
	userMgmt.getTokenByUserId(user_id, function(flag, result) {
		if (flag) {
			result.forEach(function(item) {
				var pushMsg = {
					content: content,
					badge: item.count
				};

				conn.pushMsgToUsers(item.device_token, pushMsg);

				log.debug('count ' + item.count, log.getFileNameAndLineNum(__filename));

				userMgmt.updateDeviceNotifyCount(item.device_token, item.count + 1,
					function(flag, result) {
						if (!flag) {
							log.error(result, log.getFileNameAndLineNum(__filename));
						}
					});

				return;
			});
		}
	});
}

router.post('/deleteContent', function(req, res) {
	contentMgmt.deleteContent(req.body.content_id, function(flag, result) {
		routeFunc.feedBack(flag, result, res);
	});

	//delete content image
	contentMgmt.getContentImage(req.body.content_id, function(flag, result) {
		if (flag) {
			result.forEach(function(item) {
				var image_url = item.image_url;
				var image_compress_url = item.image_compress_url;

				image_url = image_url.substr(image_url.lastIndexOf('name=') + 5);
				image_compress_url = image_compress_url.substr(image_compress_url.lastIndexOf(
					'name=') + 5);

				var fullImageName = path.join(global_config.env.homedir, config.imageInfo
					.imageRootDir, image_url);
				var fullCompressImageName = path.join(global_config.env.homedir,
					config.imageInfo.imageRootDir, image_compress_url);

				log.debug(fullImageName, log.getFileNameAndLineNum(__filename));
				log.debug(fullCompressImageName, log.getFileNameAndLineNum(__filename));

				imageOper.deleteImage(fullImageName);
				imageOper.deleteImage(fullCompressImageName);
			});

			contentMgmt.deleteContentImage(req.body.content_id, function(flag,
				result) {
				if (!flag) {
					log.error(result, log.getFileNameAndLineNum(__filename));
				}
			});

		} else {
			log.error(result, log.getFileNameAndLineNum(__filename));
		}
	});


});

// add by wanghan 20141219 for add active comment
router.post('/addCommentToContent', function(req, res) {
	contentMgmt.addCommentToContent(req.body, function(flag, result) {
		if (flag) {
			// apn
			if (req.body.to_user_id === req.body.user_id) {
				log.debug('not to apn', log.getFileNameAndLineNum(__filename));
			} else {

				apnToUser(req.body.to_user_id, req.body.user_name + '评论了你');
				redisOper.increaseUnreadCommentCount(req.body.to_user_id);
			}
		}

		routeFunc.feedBack(flag, result, res);
	});
});

router.post('/reportContent', function(req, res) {
	contentMgmt.insertReportContent(req.body, function(flag, result) {
		routeFunc.feedBack(flag, result, res);
	});
});

//#171
router.post('/getfollowContent', function(req, res){
	contentMgmt.getfollowContent(req.body, function(flag, result){
		packageContentArray(flag, result, res);
	});
});


// router.get('/converContentImage', function(req, res){
//     log.info(JSON.stringify(req.body), log.getFileNameAndLineNum(__filename));
//     databaseOperation.getAllContentImage(function(flag, result){
//         if (flag) {
//             result.forEach(function(item){

//                 var begin = item.image_url.lastIndexOf('name=');
//                 var fileName = item.image_url.substr(begin+5, item.image_url.length - begin - 5);

//                 var fullFileName =
//                 path.join(global_config.env.homedir, config.imageInfo.imageRootDir, fileName);

//                 log.info(fullFileName, log.getFileNameAndLineNum(__filename));

//                 updateImage(fullFileName, fullFileName, fullFileName+'_compress');

//             });

//         }else{
//             log.error(result, log.getFileNameAndLineNum(__filename));
//         }

//         feedBack(flag, result, res);
//     });

// });

module.exports = router;
