var log = require('../utility/log');
log.SetLogFileName('logCrawler_');
global.log = log; // 设置全局

var global_config;

if (process.env.ENV === 'dev') {
	global_config = require('../config/dev_env_config');
}

if (process.env.ENV === 'pro') {
	global_config = require('../config/pro_env_config');
}

global.global_config = global_config;
var express = require('express');
var path = require('path');
var bodyParser = require('body-parser');


var port = global_config.crawler.listen_port;
var email = require('../utility/emailTool');
var morgan = require('morgan');
var fs = require('fs');
var crawlerRouter = require('crawlerRouter.js');

process.on('uncaughtException', function (err) {
    log.error('crawler Caught exception: ' + err.stack, log.getFileNameAndLineNum(__filename));
    email.sendMail('HTTP SERVER Caught exception: ' + err.stack, 'crawler process failed');
});


global.app = express(); // 创建express实例

global.app.use(bodyParser.json()); //支持json
global.app.use(bodyParser.urlencoded({
    extended: false
})); //支持form数据

var accessLogStream = fs.createWriteStream(__dirname + '/crawlerAccess.log', {
    flags: 'a',
    encoding: 'utf-8'
});//访问日志


global.app.use(morgan('short', {
    stream: accessLogStream
}));

// 该路由使用的中间件
global.app.use(function (req, res, next) {
    log.info(JSON.stringify(req.body), log.getFileNameAndLineNum(__filename));
    next();
});

global.app.use('/', crawlerRouter);

global.app.listen(port);
log.logPrint(config.logLevel.INFO, 'Express started on port ' + port);
