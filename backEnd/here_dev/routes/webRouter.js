

var express = require('express');
var router = express.Router();
var config = require('../config/config');


//
router.get('/test', function(req, res) {
	// log.logPrint(config.logLevel.INFO, JSON.stringify(req.body));
	res.send('test');
});


router.get('/login', function(req, res){
	res.render('login');
});

router.get('/index', function(req, res){
	if(!req.session.user){
		res.redirect('/login');
	}

	res.render('index');
});

router.post('/login', function(req, res){
	console.log(req.body.name);
	console.log(req.body.password);
	if(config.mgmtUserInfo.name === req.body.name&&config.mgmtUserInfo.password === req.body.password){
		console.log('validate successful');
		req.session.user = req.body.name;
		res.redirect('/index');
	}else{
		console.log('validate not successful');
		res.redirect('/login');
	}
});




module.exports = router;
