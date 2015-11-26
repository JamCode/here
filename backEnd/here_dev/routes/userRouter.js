var express = require('express');
var formidable = require('formidable');
var userMgmt = require('../database/userMgmt.js');
var contentMgmt = require('../database/contentMgmt.js');

var config = require('../config/config');
var global_config = global.global_config;

var routeFunc = require('./routeFunc.js');

var router = express.Router();
var fs = require('fs');
var path = require('path');
var conn = require('../database/utility.js');
var log = global.log;
var redis = require('redis');
var redis_client = redis.createClient();
var imageOper = require('../utility/imageOper');
var async = require('async');
var os = require('os');
var networkInterface = os.networkInterfaces();

var imageHomeUrl = 'http://' + networkInterface.eth1[0].address + ':' +
	global_config.httpServerInfo.listen_port + config.imageInfo.url;

log.debug(imageHomeUrl, log.getFileNameAndLineNum(__filename));

redis_client.on('error', function(err) {
	log.error(err, log.getFileNameAndLineNum(__filename));
	//  process.exit(-1);
});

//  该路由使用的中间件
//  router.use(function (req, res, next) {
//  	log.info(JSON.stringify(req.body), log.getFileNameAndLineNum(__filename));
//    	next();
//  });

// logout
router.post('/logout', function(req, res) {
	// log.logPrint(config.logLevel.INFO, JSON.stringify(req.body));
	userMgmt.logout(req.body.user_id, function(flag, result) {
		routeFunc.feedBack(flag, result, res);
	});
});

// login
router.post('/login', function(req, res) {
	// log.logPrint(config.logLevel.INFO, JSON.stringify(req.body));
	userMgmt.login(req.body.user_phone, req.body.password, function(flag, result) {
		var statusCode;
		var returnData = {};
		if (flag) {
			if (result.length) {
				statusCode = config.returnCode.LOGIN_SUCCESS;

				returnData = {
					'user_phone': result[0].user_phone,
					'user_id': result[0].user_id,
					'password': result[0].user_password,
					'user_name': result[0].user_name,
					'user_facethumbnail': result[0].user_facethumbnail,
					'user_age': result[0].user_age,
					'user_gender': result[0].user_gender,
					'user_certificated_process': result[0].user_certificated_process,
					'fans_count': result[0].user_fans_count,
					'follow_count': result[0].user_follow_count,
					'user_career': result[0].user_career,
					'user_company': result[0].user_company,
					'user_sign': result[0].user_sign,
					'user_interest': result[0].user_interest,

					'code': statusCode
				};
				log.logPrint(config.logLevel.DEBUG, returnData);
				res.send(returnData);

			} else {
				statusCode = config.returnCode.LOGIN_FAIL;
				returnData = {
					'user_phone': req.body.user_phone,
					'code': statusCode
				};
				log.logPrint(config.logLevel.DEBUG, returnData);
				res.send(returnData);
			}
		} else {
			log.logPrint(config.logLevel.ERROR, 'database error for ' + result);
			statusCode = config.returnCode.ERROR;
			returnData = {
				'code': statusCode
			};
			res.send(returnData);
		}
	});
});

// add by wanghan 20141007 for add user image
// add user image
router.post('/addImage', function(req, res) {
	// log.logPrint(config.logLevel.INFO, JSON.stringify(req.body));

	var form = new formidable.IncomingForm();
	form.parse(req, function(err, fields, files) {
		var returnData = {};

		if (err) {
			log.error('form.parse error', log.getFileNameAndLineNum(__filename));
			returnData.code = config.returnCode.ERROR;
			res.send(returnData);
			return;
		}

		var fileName = files.user_image.path + Date.now();
		fileName = conn.sha1Cryp(fileName);
		fs.rename(files.user_image.path, path.join(global_config.env.homedir,
			config.imageInfo.imageRootDir, fileName), function(err) {

			if (err) {
				log.logPrint(config.logLevel.ERROR, 'fs.rename error ' + err);
				returnData.code = config.returnCode.ERROR;
				res.send(returnData);
			} else {
				var url = imageHomeUrl + fileName;

				userMgmt.insertUserImageInfo(fields.user_id, url, Date.now(),
					function(flag, result) {
						if (flag) {
							returnData.code = config.returnCode.ADD_IMAGE_SUCCESS;
							returnData.user_image_url = url;
						} else {
							log.logPrint(config.logLevel.ERROR, 'insertUserImageInfo error ' +
								result);
							returnData.code = config.returnCode.ERROR;
						}
						res.send(returnData);
					});
			}
		});
	});
});
// end by wangnan 20141007 for add user image

router.post('/addUserBackgroundImage', function(req, res) {
	// log.logPrint(config.logLevel.INFO, JSON.stringify(req.body));

	var form = new formidable.IncomingForm();
	form.parse(req, function(err, fields, files) {

		var returnData = {};
		if (err) {
			log.error('form.parse error', log.getFileNameAndLineNum(__filename));
			returnData.code = config.returnCode.ERROR;
			res.send(returnData);
			return;
		}

		var fileName = files.user_background_image.path + Date.now();
		fileName = conn.sha1Cryp(fileName);
		fs.rename(files.user_background_image.path, path.join(global_config.env.homedir,
			config.imageInfo.imageRootDir, fileName), function(err) {

			if (err) {
				log.logPrint(config.logLevel.ERROR, 'fs.rename error ' + err);
				returnData.code = config.returnCode.ERROR;
				res.send(returnData);
			} else {
				var url = imageHomeUrl + fileName;
				userMgmt.updateUserBackgroundImage(fields.user_id, url, function(flag,
					result) {
					if (flag) {
						returnData.code = config.returnCode.ADD_IMAGE_SUCCESS;
						returnData.user_background_image_url = url;
					} else {
						log.logPrint(config.logLevel.ERROR,
							'updateUserBackgroundImage error ' + result);
						returnData.code = config.returnCode.ERROR;
					}
					res.send(returnData);
				});
			}
		});
	});

});

router.post('/changeFace', function(req, res) {
	// log.logPrint(config.logLevel.INFO, JSON.stringify(req.body));

	var form = new formidable.IncomingForm();
	form.parse(req, function(err, fields, files) {

		var returnData = {};
		if (err) {
			log.error('form.parse error', log.getFileNameAndLineNum(__filename));
			returnData.code = config.returnCode.ERROR;
			res.send(returnData);
			return;
		}

		var fileName = conn.sha1Cryp(fields.user_id + 'facethumbnail' + Date.now());
		var compressFileName = fileName + '_compress';
		// delete first
		// fs.unlink()

		log.logPrint(config.logLevel.DEBUG, fileName);

		imageOper.updateImage(files.user_image.path,
			path.join(global_config.env.homedir, config.imageInfo.imageRootDir,
				fileName),
			path.join(global_config.env.homedir, config.imageInfo.imageRootDir,
				compressFileName), {
				width: 44 * 4,
				height: 44 * 4
			});

		userMgmt.updateUserFace(fields.user_id,
			path.join(imageHomeUrl, compressFileName),
			path.join(imageHomeUrl, fileName),
			function(flag, result) {
				var returnData = {};
				if (flag) {
					log.logPrint(config.logLevel.DEBUG, 'updateUserFace SUCCESS');

					returnData.code = config.returnCode.SUCCESS;
					returnData.user_image_url = path.join(imageHomeUrl, fileName);
					returnData.facethumbnail = path.join(imageHomeUrl, compressFileName);
				} else {
					log.logPrint(config.logLevel.ERROR, result);
					returnData.code = config.returnCode.ERROR;
				}
				res.send(returnData);
			});
	});
});

function getImageName(url) {
	var begin = url.lastIndexOf('?name=');
	begin += ('?name=').length;
	var fileName = url.substr(begin, url.length - begin);
	return fileName;
}

// add by wanghan 20141009 for update user info
router.post('/updateUserInfo', function(req, res) {
	// log.logPrint(config.logLevel.INFO, JSON.stringify(req.body));

	var userInfo = {
		'user_id': req.body.user_id,
		'user_career': req.body.user_career,
		'user_company': req.body.user_company,
		'user_sign': req.body.user_sign,
		'user_interest': req.body.user_interest
	};
	userMgmt.updateUserInfo(userInfo, function(flag, result) {
		routeFunc.feedBack(flag, result, res);
	});
});

router.post('/insertBlackList', function(req, res) {
	// log.info(JSON.stringify(req.body), log.getFileNameAndLineNum(__filename));

	userMgmt.insertBlackList(req.body.user_id, req.body.counter_user_id,
		function(flag, result) {
			if (!flag) {
				log.info('result.errno' + result.errno);
				if (result.errno === 1062) {
					// primary key conflict
					flag = true;
				}
			}
			routeFunc.feedBack(flag, result, res);
		});
});

router.post('/deleteBlackList', function(req, res) {
	// log.info(JSON.stringify(req.body), log.getFileNameAndLineNum(__filename));

	userMgmt.deleteBlackList(req.body.user_id, req.body.counter_user_id,
		function(flag, result) {
			routeFunc.feedBack(flag, result, res);
		});
});

router.post('/getBlackList', function(req, res) {
	// log.info(JSON.stringify(req.body), log.getFileNameAndLineNum(__filename));

	userMgmt.getBlackList(req.body.user_id, function(flag, result) {
		routeFunc.feedBack(flag, result, res);
	});
});

// add by wanghan 20141007 for get user image
router.post('/getUserInfo', function(req, res) {
	// log.info(JSON.stringify(req.body), log.getFileNameAndLineNum(__filename));

	userMgmt.getUserDetail(req.body.user_id, function(flag, result) {
		var returnData = {
			user_image: [],
			code: 0
		};

		if (flag && result.length > 0) {
			returnData.user_id = result[0].user_id;
			returnData.user_name = result[0].user_name;
			returnData.user_facethumbnail = result[0].user_facethumbnail;
			returnData.user_face_image = result[0].user_face_image;
			returnData.user_age = result[0].user_age;
			returnData.user_birth_day = result[0].user_birth_day;
			returnData.user_gender = result[0].user_gender;
			returnData.user_career = result[0].user_career;
			returnData.user_company = result[0].user_company;
			returnData.user_sign = result[0].user_sign;
			returnData.user_interest = result[0].user_interest;
			returnData.user_background_image_url = result[0].user_background_image_url;
			returnData.good_count = result[0].good_count;
			returnData.location_latitude = result[0].location_latitude;
			returnData.location_longitude = result[0].location_longitude;

			if (result[0].city_visit_count == null) {
				log.debug('city_visit_count is null', log.getFileNameAndLineNum(
					__filename));
				returnData.city_visit_count = 0;
			} else {
				log.debug('city_visit_count is ' + result[0].city_visit_count, log.getFileNameAndLineNum(
					__filename));
				returnData.city_visit_count = result[0].city_visit_count;
			}

			contentMgmt.getContentByUser(returnData.user_id, Date.now() / 1000, 1,
				function(flag, result) {
					if (flag) {
						if (result.length > 0) {
							returnData.content = result[0].content;
							returnData.content_image_url = result[0].content_image_url;
							returnData.content_publish_timestamp = result[0].content_publish_timestamp;
						} else {
							returnData.content = '';
							returnData.content_image_url = '';
							returnData.content_publish_timestamp = 0;
						}

						var cur_timestamp = Date.now() / 1000;
						userMgmt.getUserImage(req.body.user_id, cur_timestamp, 3, function(
							flag, result) {
							if (flag) {

								result.forEach(function(item) {
									var imageInfo = {
										user_image_url: item.image_compress_url
									};
									returnData.user_image.push(imageInfo);
								});
							} else {
								log.logPrint(config.logLevel.ERROR, result);
								returnData.code = config.returnCode.ERROR;
							}

							userMgmt.checkBlackList(req.body.my_user_id, req.body.user_id,
								function(flag, result) {
									if (flag) {
										returnData.code = config.returnCode.SUCCESS;
										if (result.length > 0) {
											returnData.black = true;
										} else {
											returnData.black = false;
										}
										log.debug(JSON.stringify(returnData), log.getFileNameAndLineNum(
											__filename));
										res.send(returnData);
									} else {
										routeFunc.feedBack(flag, result, res);
									}
								});
						});

					} else {
						log.logPrint(config.logLevel.ERROR, result);
						returnData.code = config.returnCode.ERROR;
						res.send(returnData);
					}
				});

		} else {
			log.logPrint(config.logLevel.ERROR, result);
			returnData.code = config.returnCode.ERROR;
			res.send(returnData);
		}
	});
});
// end by wanghan 20141007 for get user image

router.post('/getLastVisitUser', function(req, res) {

	// log.info(JSON.stringify(req.body), log.getFileNameAndLineNum(__filename));

	userMgmt.getLastVisitUser(req.body.user_id, function(flag, result) {
		routeFunc.feedBack(flag, result, res);
	});
});

router.post('/getUserImage', function(req, res) {

	// log.info(JSON.stringify(req.body), log.getFileNameAndLineNum(__filename));

	userMgmt.getUserImage(req.body.user_id, req.body.timestamp, req.body.count,
		function(flag, result) {
			if (flag) {
				var returnData = {};
				returnData.code = config.returnCode.SUCCESS;
				returnData.data = result;
				res.send(returnData);

			} else {
				routeFunc.feedBack(flag, result, res);
			}
		});
});

// register
router.post('/register', function(req, res) {
	// log.logPrint(config.logLevel.INFO, JSON.stringify(req.body));

	var returnData = {};
	var fields = req.body;
	userMgmt.getCertificateCode(fields.user_phone, function(flag, result) {
		if (flag) {
			if (result.length === 0) {
				log.debug('no certificateCode for phone:' + fields.user_phone, log.getFileNameAndLineNum(
					__filename));
				returnData.code = config.returnCode.CERTIFICATE_CODE_NOT_MATCH;
				res.send(returnData);
				return;
			}

			var certificateInfo = result[0];

			if (certificateInfo.certificate_code === fields.user_certificate_code) {
				var user_info = {};
				var md5 = require('MD5');
				user_info.id = md5(fields.user_phone);

				// var fileName = conn.sha1Cryp(user_info.id + 'facethumbnail');
				// var imageCompressName = fileName + '_compress';

				// imageOper.updateImage(files.user_facethumbnail.path,
				// 	path.join(global_config.env.homedir, config.imageInfo.imageRootDir, fileName),
				// 	path.join(global_config.env.homedir, config.imageInfo.imageRootDir, imageCompressName), {
				// 		width: 44 * 4,
				// 		height: 44 * 4
				// 	});


				user_info.user_phone = fields.user_phone;
				user_info.name = fields.user_name;
				user_info.password = fields.user_password;
				user_info.user_gender = -1;
				var defaultImageUrl = 'http://' + networkInterface.eth1[0].address +
					':' +
					global_config.httpServerInfo.listen_port + "/default_face.png";

				user_info.user_face_image = defaultImageUrl;
				user_info.facethumbnail = defaultImageUrl;

				user_info.fans_count = 0;
				user_info.follow_count = 0;

				userMgmt.register(user_info, function(flag, result) {
					if (flag) {
						log.debug('REGISTER_SUCCESS', log.getFileNameAndLineNum(__filename));
						returnData = {
							'user_phone': user_info.user_phone,
							'user_id': user_info.id,
							'password': user_info.password,
							'user_name': user_info.name,
							'user_birth_day': user_info.user_birth_day,
							'user_gender': user_info.user_gender,
							'code': config.returnCode.REGISTER_SUCCESS
						};
					} else {
						log.error(result, log.getFileNameAndLineNum(__filename));
						returnData = {
							'user_phone': fields.user_phone,
							'code': config.returnCode.REGISTER_FAIL
						};
					}
					res.send(returnData);
				});

			} else {
				log.debug(fields.user_certificate_code + ' not equal to ' +
					certificateInfo.certificate_code, log.getFileNameAndLineNum(
						__filename));
				returnData.code = config.returnCode.CERTIFICATE_CODE_NOT_MATCH;
				res.send(returnData);
			}

		} else {
			log.error(result, log.getFileNameAndLineNum(__filename));
			returnData.code = config.returnCode.ERROR;
			res.send(returnData);
		}
	});
});

// add by wanghan 20141008
// for delete user image url
router.post('/deleteUserImage', function(req, res) {
	// log.logPrint(config.logLevel.INFO, JSON.stringify(req.body));
	userMgmt.deleteUserImage(req.body.user_id, req.body.user_image_url, function(
		flag, result) {
		var returnData = {};
		if (flag) {
			var oldFileName = getImageName(req.body.user_image_url);
			fs.unlink(path.join(global_config.env.homedir, config.imageInfo.imageRootDir,
				oldFileName), function() {
				log.logPrint(config.logLevel.DEBUG, 'delete old file ' + oldFileName);
				returnData.code = config.returnCode.DEL_IMAGE_SUCCESS;
				res.send(returnData);
			});

		} else {
			// fail to delete from database
			log.logPrint(config.logLevel.ERROR, 'deleteUserImage ' + result);
			returnData.code = config.returnCode.ERROR;
			res.send(returnData);
		}
	});
});

// end by wanghan 20141008 for delete user image url

// get the verifying code from phone number
router.post('/confirmPhone', function(req, res) {
	// log.logPrint(config.logLevel.INFO, JSON.stringify(req.body));

	userMgmt.checkPhoneNum(req.body.user_phone, function(flag, result) {
		var statusCode;
		var returnData = {
			'user_phone': req.body.user_phone,
			'code': 0
		};
		if (flag && result.length) {
			log.debug(req.body.user_phone + ' PHONE_EXIST', log.getFileNameAndLineNum(
				__filename));
			statusCode = config.returnCode.PHONE_EXIST;
			returnData.code = statusCode;
			res.send(returnData);
		} else if (flag) {

			var certificateCode = (Math.random() * config.number.numberInput).toFixed(
				0);
			var timestamp = new Date().getTime();
			userMgmt.certificateCode(req.body.user_phone, certificateCode, timestamp,
				function(flag, result) {

					if (flag && result) {
						statusCode = config.returnCode.CERTIFICATE_CODE_SEND;
						var weimi = require('../utility/weimi');
						weimi.sendMessage(req.body.user_phone, certificateCode, function(
							result) {
							log.logPrint(config.logLevel.DEBUG, result);
							returnData.code = statusCode;
							res.send(returnData);
						});
					} else if (flag) {
						statusCode = config.returnCode.CERTIFICATE_CODE_SENDED;
						returnData.code = statusCode;
						res.send(returnData);
					} else {
						statusCode = config.returnCode.ERROR;
						returnData.code = statusCode;
						res.send(returnData);
					}
				});
		} else {
			statusCode = config.returnCode.ERROR;
			returnData.code = statusCode;
			res.send(returnData);
		}
	});
});

// add by wanghan 20150124
router.post('/updateDeviceToken', function(req, res) {
	// log.logPrint(config.logLevel.INFO, JSON.stringify(req.body));

	var deviceInfo = {
		'user_id': req.body.user_id,
		'device_token': req.body.device_token
	};

	userMgmt.updateDeviceToken(deviceInfo, function(flag, result) {
		routeFunc.feedBack(flag, result, res);
	});

	userMgmt.getDeviceNotifyCount(deviceInfo.device_token, function(flag, result) {
		if (result.length === 0) {
			userMgmt.insertDeviceNotifyCount(deviceInfo.device_token, 0, function(
				flag, result) {
				if (!flag) {
					log.logPrint(config.logLevel.ERROR, result);
				}
			});
		} else {
			userMgmt.updateDeviceNotifyCount(deviceInfo.device_token, 0, function(
				flag, result) {
				if (!flag) {
					log.logPrint(config.logLevel.ERROR, result);
				}
			});
		}
	});

});

// add by wanghan 20150325 for get unread comment
router.post('/getUnreadComments', function(req, res) {

	userMgmt.getUnreadComments(req.body.user_id, req.body.timestamp, function(
		flag, result) {
		routeFunc.feedBack(flag, result, res);
	});
	redis_client.hset(config.hashKey.commentUnreadCount, req.body.user_id, 0);

});

router.post('/getUnreadGood', function(req, res) {

	userMgmt.getUnreadGood(req.body, function(flag, result) {
		routeFunc.feedBack(flag, result, res);
	});

	redis_client.hset(config.hashKey.goodUnreadCount, req.body.user_id, 0);
});

// add by wanghan 20150328 for get notice msg count
router.post('/getNoticeMsgCount', function(req, res) {
	// log.logPrint(config.logLevel.INFO, JSON.stringify(req.body));

	log.debug(req.body.user_id, log.getFileNameAndLineNum(__filename));

	async.series([
			function(callback) {
				//  do some stuff ...
				redis_client.hget(config.hashKey.commentUnreadCount, req.body.user_id,
					function(err, reply) {
						if (err) {
							log.error(err, log.getFileNameAndLineNum(__filename));
							callback(err, reply);
						} else {
							if (reply == null) {
								reply = parseInt(0, 10);
							}
							callback(null, reply);
						}
					});
			},
			function(callback) {
				//  do some more stuff ...
				redis_client.hget(config.hashKey.goodUnreadCount, req.body.user_id,
					function(err, reply) {
						if (err) {
							log.error(err, log.getFileNameAndLineNum(__filename));
							callback(err, reply);
						} else {
							log.debug(req.body.user_id + ' ' + config.hashKey.goodUnreadCount +
								' ' + reply,
								log.getFileNameAndLineNum(__filename));
							if (reply == null) {
								reply = parseInt(0, 10);
							}
							callback(null, reply);
						}
					});
			},
			function(callback) {
				//  do some more stuff ...
				redis_client.hget(config.hashKey.commentGoodUnreadCount, req.body.user_id,
					function(err, reply) {
						if (err) {
							log.error(err, log.getFileNameAndLineNum(__filename));
							callback(err, reply);
						} else {
							log.debug(req.body.user_id + ' ' + config.hashKey.commentGoodUnreadCount +
								' ' + reply,
								log.getFileNameAndLineNum(__filename));
							if (reply == null) {
								reply = parseInt(0, 10);
							}
							callback(null, reply);
						}
					});
			}
		],
		//  optional callback
		function(err, results) {

			var resultData = {};

			if (err) {
				log.error(err, log.getFileNameAndLineNum(__filename));
				resultData.code = config.returnCode.ERROR;
			} else {
				log.debug('unread notice msg count: ' + results, log.getFileNameAndLineNum(
					__filename));
				resultData.data = results[0] + results[1] + results[2];
				resultData.unreadCommentsCount = results[0];
				resultData.unreadGoodCount = results[1];
				resultData.unreadCommentGoodCount = results[2];
				resultData.code = config.returnCode.SUCCESS;
			}
			res.send(resultData);
		});
});

router.post('/updateLocation', function(req, res) {
	// log.logPrint(config.logLevel.INFO, JSON.stringify(req.body));

	res.setHeader('request_time', Date.now());

	var locationInfo = {
		'user_id': req.body.user_id,
		'latitude': req.body.latitude,
		'longitude': req.body.longitude,
		'timeStamp': 0
	};
	userMgmt.updateLocationInfo(locationInfo, function(flag, result) {
		routeFunc.feedBack(flag, result, res);
	});
});

router.post('/nearbyPerson', function(req, res) {
	// log.logPrint(config.logLevel.INFO, JSON.stringify(req.body));

	var locationInfo = {
		'user_id': req.body.user_id,
		'latitude': req.body.latitude,
		'longitude': req.body.longitude
	};

	var returnData = {
		persons: [],
		code: 0
	};
	userMgmt.findNearbyUser(locationInfo, function(nearbyUserFlag,
		locationInfoResult) {
		if (nearbyUserFlag) {
			log.logPrint(config.logLevel.DEBUG, 'get nearby person ok');

			returnData.persons = locationInfoResult;
			returnData.code = config.returnCode.SUCCESS;
		} else {
			log.logPrint(config.logLevel.ERROR, JSON.stringify(req.body));
			returnData.code = config.returnCode.ERROR;
		}
		res.send(returnData);
	});
});


router.post('/updateUserGender', function(req, res) {
	userMgmt.updateUserGender(req.body, function(flag, result) {
		routeFunc.feedBack(flag, result, res);
	});
});

router.post('/updateBirthDay', function(req, res) {
	userMgmt.updateBirthDay(req.body, function(flag, result) {
		routeFunc.feedBack(flag, result, res);
	});
});

router.post('/checkNameExist', function(req, res) {
	userMgmt.checkUserNameExist(req.body, function(flag, result) {
		var returnData = {};
		if (flag) {
			if (result.length > 0) {
				log.debug(req.body.user_name + ' USER_EXIST', log.getFileNameAndLineNum(
					__filename));
				returnData.code = config.returnCode.USER_EXIST;
			} else {
				log.debug(req.body.user_name + ' USER_NOT_EXIST', log.getFileNameAndLineNum(
					__filename));
				returnData.code = config.returnCode.USER_NOT_EXIST;
			}
		} else {
			log.error(result, log.getFileNameAndLineNum(__filename));
			returnData.code = config.returnCode.ERROR;
		}
		res.send(returnData);
	});
});

router.post('/getAllVisit', function(req, res) {
	// log.info(JSON.stringify(req.body), log.getFileNameAndLineNum(__filename));

	userMgmt.getAllVisitRecord(req.body.user_id, req.body.timestamp, function(
		flag, result) {
		routeFunc.feedBack(flag, result, res);
	});
});

router.post('/visit', function(req, res) {
	// log.info(JSON.stringify(req.body), log.getFileNameAndLineNum(__filename));

	var returnData = {};
	var body = req.body;

	userMgmt.getVisitRecord(req.body.user_id, req.body.visit_user_id, function(
		flag, result) {
		if (flag) {
			if (result.length > 0) {
				// update visit record
				log.debug('updateVisitRecord', log.getFileNameAndLineNum(__filename));
				userMgmt.updateVisitRecord(req.body.user_id, req.body.visit_user_id,
					function(flag, result) {

						if (flag) {
							returnData.code = config.returnCode.SUCCESS;
							res.send(returnData);
						} else {
							log.error(result, log.getFileNameAndLineNum(__filename));
							returnData.code = config.returnCode.ERROR;
							res.send(returnData);
						}

					});
			} else {
				// insert visit record
				log.debug('insertVisitRecord', log.getFileNameAndLineNum(__filename));
				userMgmt.insertVisitRecord(req.body.user_id, req.body.visit_user_id,
					function(flag, result) {
						// feedBack(flag, result, res);
						if (flag) {
							returnData.code = config.returnCode.SUCCESS;
							res.send(returnData);
						} else {
							log.error(result, log.getFileNameAndLineNum(__filename));
							returnData.code = config.returnCode.ERROR;
							res.send(returnData);
						}
					});
			}
		} else {
			routeFunc.feedBack(flag, result, res);
		}
	});

	userMgmt.getUserTokenInfo(req.body.user_id, function(flag, result) {
		if (flag) {
			if (result.length > 0) {
				var pushMsg = {
					content: body.visit_user_name + '查看了你的资料',
					msgtype: 'msg',
					badge: result[0].count
				};
				// apn to user
				conn.pushMsgToUsers(result[0].device_token, pushMsg);
			} else {
				log.warn(body.user_id + ' has no device token', log.getFileNameAndLineNum(
					__filename));
			}

		} else {
			log.error(result, log.getFileNameAndLineNum(__filename));
		}
	});
});

router.post('/addToUserCollectList', function(req, res) {
	// log.info(JSON.stringify(req.body), log.getFileNameAndLineNum(__filename));

	userMgmt.addToUserCollectList(req.body.user_id, req.body.content_id,
		function(flag, result) {
			if (flag) {
				contentMgmt.addSeeCount(req.body.content_id, function(flag, result) {
					// feedBack(flag, result, res);
				});
			}
			routeFunc.feedBack(flag, result, res);
		});
});

router.post('/submitFeedback', function(req, res) {
	userMgmt.submitFeedback(req.body, function(flag, result) {
		routeFunc.feedBack(flag, result, res);
	});
});

router.get('/testfile', function(req, res) {
	res.send('testfile');
});

module.exports = router;
