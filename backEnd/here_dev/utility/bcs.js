// var formidable = require('formidable');
// var request = require('request');
// var fs = require('fs');
// var config = require('../config/config');

// exports.uploadFile = function(uploadInfo, callback){
// 	var filename = generateSignature(uploadInfo);
// 	var url = config.bcsInfo.url + '/images'+'?name=' + filename;
// 	var req = request.post(url, function(error, response, body){
// 		if (error) {
// 			if (callback && typeof callback === 'function') callback(false);
// 		} else{
// 			if (callback && typeof callback === 'function') callback(true, url);
// 		}
// 	});
// 	var form = req.form();
// 	form.append('file', fs.createReadStream(path.join(global.app.get('imagePath'), filename)));
// }

// exports.deleteFile = function(uploadInfo, callback){
// 	var url = config.bcsInfo.url + '/' + uploadInfo.bucket + uploadInfo.object + '?sign=' + generateSignature(uploadInfo);
// 	var req = request.del(url, function(error, response, body){
// 		if (error) {
// 			if (callback && typeof callback === 'function') callback(false);
// 		} else{
// 			if (callback && typeof callback === 'function') callback(true, url);
// 		}
// 	});
// }

// function generateSignature(signatureInfo){
// 	var content = config.bcsInfo.flag + '\n'
// 				   + 'Method=' + signatureInfo.method + '\n'
// 				   + 'Bucket=' + signatureInfo.bucket + '\n'
// 				   + 'Object=' + signatureInfo.object + '\n';
// 	var signature = require('crypto').createHmac('sha1', config.aksk.secretKey).update(content).digest().toString('base64');
// 	var sign = config.bcsInfo.flag + ':' + config.aksk.accessKey + ':' + encodeURIComponent(signature);
// 	return sign;
// }
