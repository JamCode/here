var express = require('express');
var router = express.Router();
var log = global.log;


router.get('/', function (req, res) {
	// log.logPrint(config.logLevel.INFO, JSON.stringify(req.body));
	res.send("hello crawler");
});

module.exports = router;
