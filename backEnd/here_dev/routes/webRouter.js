

var express = require('express');
var router = express.Router();



//
router.get('/test', function(req, res) {
	// log.logPrint(config.logLevel.INFO, JSON.stringify(req.body));
	res.send('test');
});


router.get('/login', function(req, res){
	res.render('message.html');
});

router.get('/index', function(req, res){
    res.render('socketTest');
});



module.exports = router;
