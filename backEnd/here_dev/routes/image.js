var express = require('express');
var formidable = require('formidable');
var config = require('../config/config');
var global_config = global.global_config;
var log = global.log;

var fs = require('fs');
var router = express.Router();
var path = require('path');
var gm = require('gm').subClass({ imageMagick: true });


router.get('/', function(req, res){

	//log.info(JSON.stringify(req.body), log.getFileNameAndLineNum(__filename));

	var filePath = path.join(global_config.env.homedir, config.imageInfo.imageRootDir, req.query.name);
	fs.exists(filePath, function(exists){
		if (exists) {
			res.sendFile(filePath);
		}else{
			log.logPrint(config.logLevel.ERROR, filePath+" not exists");
			//res.sendFile(path.join(global_config.env.homedir, config.imageInfo.imageRootDir, "loading.png"));
		}
	});
	//res.send("hello image"+filePath);
});








module.exports = router;