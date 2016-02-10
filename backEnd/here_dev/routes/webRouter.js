

var express = require('express');
var router = express.Router();
var config = require('../config/config');
var contentMgmt = require('../database/contentMgmt.js');
var log = global.log;


//
router.get('/test', function(req, res) {
	// log.logPrint(config.logLevel.INFO, JSON.stringify(req.body));
	res.send('test');
});


router.get('/login', function(req, res){
	res.render('login');
});


router.get('/content', function(req, res){
	if(!req.session.user){
		res.redirect('/login');
		return;
	}

	global.user = req.session.user;
	var page = req.query.page;
	console.log(page);
	if(page == null){
		page = 1;
	}

	//res.redirect('/login');

	console.log('enter getReportContent');

	contentMgmt.getReportContent(page, function(flag, result){
		if(flag){
			//res.send('test');
			//res.render('index', {'result':result, 'page':page});
			res.render('content', {'result':result, 'page':page});
			//res.render('socketTest');

		}else{
			log.error(result, log.getFileNameAndLineNum(__filename));
		}
	});
});

// router.get('/index', function(req, res){
// 	if(!req.session.user){
// 		res.redirect('/login');
// 	}
//
// 	var page = req.query.page;
// 	console.log(page);
// 	if(page == null){
// 		page = 1;
// 	}
//
// 	//res.redirect('/login');
//
// 	contentMgmt.getReportContent(page, function(flag, result){
// 		if(flag){
// 			//res.send('test');
// 			//res.render('index', {'result':result, 'page':page});
// 			res.render('index');
// 			//res.render('socketTest');
//
// 		}else{
// 			log.error(result, log.getFileNameAndLineNum(__filename));
// 		}
// 	});
// });

router.get('/logout', function(req, res){
	req.session.user = null;
	global.user = null;
	res.redirect('/login');
});

router.post('/login', function(req, res){
	console.log(req.body.name);
	console.log(req.body.password);
	if(config.mgmtUserInfo.name === req.body.name&&config.mgmtUserInfo.password === req.body.password){
		console.log('validate successful');
		req.session.user = req.body.name;

		res.redirect('/content?page=1');
	}else{
		console.log('validate not successful');
		res.redirect('/login');
	}
});




module.exports = router;
