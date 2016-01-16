

var express = require('express');
var router = express.Router();



//
router.get('/test', function(req, res) {
	// log.logPrint(config.logLevel.INFO, JSON.stringify(req.body));
	res.send('test');
});


router.get('/index', function(req, res){
    res.sendfile('message.html');
});

module.exports = router;
