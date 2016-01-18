

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

router.post('/login', function(req, res){
	console.log(req.body.name);
	console.log(req.body.password);
	if(config.mgmtUserInfo.name === req.body.name&&config.mgmtUserInfo.password === req.body.password){
		console.log('validate successful');
		res.flash('success', '登入成功');
	}else{
		console.log('validate not successful');
		res.flash('error', '用户或密码错误');
		res.redirect('/login');
	}
});


router.get('/index', function(req, res){
    res.render('socketTest');
});



module.exports = router;
