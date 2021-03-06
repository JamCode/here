var express = require('express');
var config = require('../config/config');
var global_config = global.global_config;
var log = global.log;

var fs = require('fs');
var router = express.Router();
var path = require('path');

router.get('/', function (req, res) {
	var filePath = path.join(global_config.env.homedir, config.imageInfo.imageRootDir, req.query.name);
	log.debug(filePath, log.getFileNameAndLineNum(__filename));
	fs.exists(filePath, function (exists) {
		if (exists) {
			res.sendFile(filePath);
		}else {
			log.error(filePath + ' not exists', log.getFileNameAndLineNum(__filename));
		}
	});
});

module.exports = router;
