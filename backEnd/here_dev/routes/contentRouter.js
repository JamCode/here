var express = require('express');
var formidable = require('formidable');
var contentMgmt = require('../database/contentMgmt.js')
var userMgmt = require('../database/userMgmt.js');

var config = require('../config/config');

var global_config = global.global_config;

var router = express.Router();

var gm = require('gm').subClass({
	imageMagick: true
});
var fs = require('fs');
var path = require('path');
var conn = require('../database/utility.js');
var log = global.log;

var routeFunc = require('./routeFunc.js');
var imageOper = require('../utility/imageOper');
var redis = require('redis');
var redis_client = redis.createClient();
var async = require('async');
var os = require('os');
var networkInterface = os.networkInterfaces();
console.log('networkInterface '+networkInterface.eth1.address);

var imageHomeUrl = global_config.httpServerInfo.url + ":" + global_config.httpServerInfo.listen_port + config.imageInfo.url;

log.info(imageHomeUrl, log.getFileNameAndLineNum(__filename));



router.post('/getAllContentLocation', function(req, res) {
	//log.logPrint(config.logLevel.INFO, JSON.stringify(req.body));
	contentMgmt.getAllContentLocation(req.body.user_id, function(flag, result) {
		routeFunc.feedBack(flag, result, res);
	});
});


router.post('/getMyContentByCity', function(req, res) {
	//log.logPrint(config.logLevel.INFO, JSON.stringify(req.body));
	contentMgmt.getMyContentByCity(req.body.user_id, req.body.city_desc, function(flag, result) {
		packageContentArray(flag, result, res);
	});
});

//add by wanghan 20141129 for publish active
router.post('/publishContent', function(req, res) {

	//log.info(JSON.stringify(req.body), log.getFileNameAndLineNum(__filename));


	if (req.body.imageCount == 0) {
		var timestamp = Date.now() / 1000;
		var content_id = conn.sha1Cryp(req.body.user_id + timestamp);

		req.body.content_id = content_id;
		req.body.timestamp = timestamp;

		//routeFunc.feedBack(true, 'ok', res);
		contentMgmt.insertContent(req.body, function(flag, result) {
			log.debug(JSON.stringify(result), log.getFileNameAndLineNum(__filename));
			routeFunc.feedBack(flag, result, res);
		});
	} else {

		log.debug('has image', log.getFileNameAndLineNum(__filename));

		var form = new formidable.IncomingForm();
		form.parse(req, function(err, fields, files) {

			req.body = fields;
			log.info(JSON.stringify(req.body), log.getFileNameAndLineNum(__filename));

			var timestamp = Date.now() / 1000;
			log.debug(req.body.user_id + timestamp, log.getFileNameAndLineNum(__filename));

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

				if(i == 0){
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

				var fullFileName = path.join(global_config.env.homedir, config.imageInfo.imageRootDir, fileName);
				var fullFileNameCompress = fullFileName + '_compress';



				imageOper.updateImage(files['content_image_' + i].path, fullFileName, fullFileNameCompress, {
					width: 66 * 4,
					height: 66 * 4
				});
			}


			contentMgmt.insertContent(req.body, function(flag, result) {
				routeFunc.feedBack(flag, result, res);
			});


			//updateImage(files.content_image.path, fullFileName, fullFileNameCompress);
			//updateImage(files.content_image.path, path.join(global_config.env.homedir, config.imageInfo.imageRootDir, fileName+'_compress'), 4);

		});
	}
});


function feedBack(flag, result, res) {
	//log.info(result, log.getFileNameAndLineNum(__filename));

	var returnData = {};
	if (flag) {
		returnData.code = config.returnCode.SUCCESS;
		returnData.data = result;
	} else {
		log.error(result, log.getFileNameAndLineNum(__filename));
		returnData.code = config.returnCode.ERROR;
		//email.sendMail(result);

	}
	log.debug(JSON.stringify(returnData), log.getFileNameAndLineNum(__filename));
	res.send(returnData);
}


function updateImage(origfilePath, fullFileName, fullFileNameCompress) {
	fs.rename(origfilePath, fullFileName, function(err) {
		var returnData = {};
		if (err) {
			log.error("fs.rename error " + err, log.getFileNameAndLineNum(__filename));
		} else {

			log.info(fullFileName, log.getFileNameAndLineNum(__filename));
			gm(fullFileName).size(function(err, size) {
				if (!err) {
					gm(fullFileName).resize(size.width / 4, size.height / 4, '!').write(fullFileNameCompress, function(err) {
						if (err) {
							log.error(err, log.getFileNameAndLineNum(__filename));
						}
					});

				} else {
					log.error(err, log.getFileNameAndLineNum(__filename));
				}
			});
		}
	});
}



function packageContentArray(flag, result, res) {
	var statusCode;
	var returnData = {
		contents: {},
		code: 0
	};
	if (flag) {
		statusCode = config.returnCode.SUCCESS;
		var contentInfoDic = {};

		result.forEach(function(item) {
			if (contentInfoDic[item.content_id] == null) {
				var activeInfo = {
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
					user_gender: item.user_gender,
					anonymous: item.anonymous,
					content_image_url: item.content_image_url,
					address: item.address,
					content_image_url_array: [],
					content_image_compress_url_array: []
				};
				if (item.image_url != null) {
					activeInfo.content_image_url_array.push(item.image_url);
					activeInfo.content_image_compress_url_array.push(item.image_compress_url);
				}
				//contentInfoDic.push(item.content_id, activeInfo);
				contentInfoDic[item.content_id] = activeInfo;
			} else {
				var activeInfo = contentInfoDic[item.content_id];
				if (item.image_url != null) {
					activeInfo.content_image_url_array.push(item.image_url);
					activeInfo.content_image_compress_url_array.push(item.image_compress_url);
				}
				//contentInfoDic.push(item.content_id, activeInfo);
				contentInfoDic[item.content_id] = activeInfo;
			}
		});


		returnData.contents = contentInfoDic;
	} else {
		log.logPrint(config.logLevel.ERROR, "getContent error with detail:" + result);
		statusCode = config.returnCode.ERROR;
	}

	returnData.code = statusCode;
	res.send(returnData);
}



//add by wanghan 20141226 for get nearby content
router.post('/getNearbyContent', function(req, res) {
	//log.info(JSON.stringify(req.body), log.getFileNameAndLineNum(__filename));

	contentMgmt.getNearbyContent(req.body, function(flag, result) {
		packageContentArray(flag, result, res);
	});
});

router.post('/getContentByUser', function(req, res) {
	//log.info(JSON.stringify(req.body), log.getFileNameAndLineNum(__filename));

	var anonymous;
	if (req.body.user_id == req.body.my_user_id) {
		log.logPrint(config.logLevel.DEBUG, 'anonymous is true');
		anonymous = true;
	} else {
		log.logPrint(config.logLevel.DEBUG, 'anonymous is false');
		anonymous = false;
	}

	contentMgmt.getContentByUser(req.body.user_id, req.body.last_timestamp, anonymous, function(flag, result) {
		packageContentArray(flag, result, res);
	});
});

router.post('/getHisContentByUser', function(req, res) {
	//log.info(JSON.stringify(req.body), log.getFileNameAndLineNum(__filename));

	contentMgmt.getHisContentByUser(req.body.user_id, req.body.last_timestamp, function(flag, result) {
		packageContentArray(flag, result, res);
	});
});



router.post('/getAllContentByUser', function(req, res) {
	//log.info(JSON.stringify(req.body), log.getFileNameAndLineNum(__filename));

	contentMgmt.getAllContentByUser(req.body.user_id, function(flag, result) {
		routeFunc.feedBack(flag, result, res);
	});
});


router.post('/getContentBaseInfo', function(req, res) {

	//log.info(JSON.stringify(req.body), log.getFileNameAndLineNum(__filename));

	contentMgmt.getContentBaseInfo(req.body.content_id, function(flag, result) {
		packageContentArray(flag, result, res);
	});

});



//add by wanghan 20141231 for get popular content
router.post('/getPopularContent', function(req, res) {
	//log.info(JSON.stringify(req.body), log.getFileNameAndLineNum(__filename));

	contentMgmt.getPopularContent(req.body, function(flag, result) {
		packageContentArray(flag, result, res);
	});
});


router.post('/getContentCommentsList', function(req, res) {
	//log.logPrint(config.logLevel.INFO, JSON.stringify(req.body));

	contentMgmt.getContentCommentsList(req.body.content_id, function(flag, result) {
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
					to_content: item.to_content
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
	//log.logPrint(config.logLevel.INFO, JSON.stringify(req.body));

	contentMgmt.addSeeCount(req.body.content_id, function(flag, result) {
		routeFunc.feedBack(flag, result, res);
	});
});

//end by wanghan 20141219 for add active comment

router.post('/addGoodCount', function(req, res) {
	//log.logPrint(config.logLevel.INFO, addGoodCount.stringify(req.body));

	contentMgmt.addGoodCount(req.body.content_id, req.body.user_id, function(flag, result) {
		if (flag && result) {
			//cannot click good for one content mutiple time
			log.debug('before updateGoodCount and insertGoodInfo', log.getFileNameAndLineNum(__filename));
			if (result.length == 0) {

				log.debug('updateGoodCount and insertGoodInfo', log.getFileNameAndLineNum(__filename));
				contentMgmt.updateGoodCount(req.body.content_id);
				contentMgmt.insertGoodInfo(req.body.content_id, req.body.user_id);


				if(req.body.content_user_id !== req.body.user_id){
					log.debug(req.body.content_user_id+", "+req.body.user_id);
					apnAndUpdateMem(req.body.user_id, req.body.user_name+"赞了你的状态", config.hashKey.goodUnreadCount, req.body.user_id);
				}

			} else {
				log.debug("already in good info", log.getFileNameAndLineNum(__filename));
			}
		}else{
			log.debug(result, log.getFileNameAndLineNum(__filename));
		}
		routeFunc.feedBack(flag, result, res);
	});
});


function apnAndUpdateMem(user_id, content, key, field) {
	//apn push
	userMgmt.getTokenByUserId(user_id, function(flag, result) {
		if (flag) {
			result.forEach(function(item) {
				var pushMsg = {
					content:content,
					badge: item.count,
				};

				conn.pushMsgToUsers(item.device_token, pushMsg);

				log.debug("count " + item.count, log.getFileNameAndLineNum(__filename));

				userMgmt.updateDeviceNotifyCount(item.device_token, item.count + 1, function(flag, result) {
					if (!flag) {
						log.error(result, log.getFileNameAndLineNum(__filename));
					}
				});

				return;
			});

			//input unread good count to redis
			
			redis_client.hget(key, field, function(err, reply) {
				if (err) {
					log.error(err, log.getFileNameAndLineNum(__filename));
					return;
				}

				if (reply === null) {
					reply = 1;
				} else {
					reply = parseInt(reply) + 1;
				}
				redis_client.hset(key, field, reply);
			});
		}
	});
}


router.post('/deleteContent', function(req, res) {
	//log.logPrint(config.logLevel.INFO, JSON.stringify(req.body));

	contentMgmt.deleteContent(req.body.content_id, function(flag, result) {
		routeFunc.feedBack(flag, result, res);
	});
});


//add by wanghan 20141219 for add active comment
router.post('/addCommentToContent', function(req, res) {
	//log.logPrint(config.logLevel.INFO, JSON.stringify(req.body));

	contentMgmt.addCommentToContent(req.body, function(flag, result) {
		if (flag) {
			//apn

			if (req.body.to_user_id == req.body.user_id) {
				log.debug('not to apn', log.getFileNameAndLineNum(__filename));
			} else {

				apnAndUpdateMem(req.body.to_user_id, req.body.user_name + "评论了你", config.hashKey.commentUnreadCount, req.body.to_user_id);
			}
		}

		routeFunc.feedBack(flag, result, res);
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