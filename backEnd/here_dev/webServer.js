var log = require('./utility/log');
log.SetLogFileName('logServer_');
global.log = log; // 设置全局

var global_config;

if (process.env.ENV === 'dev') {
	global_config = require('./config/dev_env_config');
}

if (process.env.ENV === 'pro') {
	global_config = require('./config/pro_env_config');
}

global.global_config = global_config;

var http = require('http');
var express = require('express');
var path = require('path');
var bodyParser = require('body-parser');

var config = require('./config/config');

var cluster = require('cluster');
var email = require('./utility/emailTool');

var fs = require('fs');
var morgan = require('morgan');
var fileStreamRotator = require('file-stream-rotator');
var webRouter = require('./routes/webRouter.js');


process.on('uncaughtException', function(err) {
    log.error('web SERVER Caught exception: ' + err.stack, log.getFileNameAndLineNum(
        __filename));
    email.sendMail('web SERVER Caught exception: ' + err.stack,
        'server process failed');
});


global.app = express(); // 创建express实例

// view engine setup
global.app.set('views', path.join(__dirname, 'views'));
global.app.set('view engine', 'ejs');
global.app.set('imagePath', path.join(__dirname, 'images'));
app.use(session({
	secret: '12345',
    name: 'webserver',   //这里的name值得是cookie的name，默认cookie的name是：connect.sid
    cookie: {maxAge: 80000 },  //设置maxAge是80000ms，即80s后session和相应的cookie失效过期
    resave: false,
    saveUninitialized: true,
}));

global.app.use(bodyParser.json());
global.app.use(bodyParser.urlencoded({
    extended: false
}));

// create a rotating write stream
var accessLogStream = fileStreamRotator.getStream({
    filename: path.join(global_config.env.homedir,
        'logs', '/webServer_access_%DATE%.log'),
    frequency: 'daily',
    verbose: false,
    date_format: "YYYY-MM-DD"
});

global.app.use(morgan('short', {
    stream: accessLogStream
}));

// 消息生成唯一码
global.app.use(function(req, res, next) {
    req.body.sq = Date.now();
    log.info(JSON.stringify(req.body), log.getFileNameAndLineNum(__filename),
        req.body.sq);
    next();
});

global.app.use('/', webRouter);
global.app.use(express.static(__dirname + '/css'));
global.app.use(express.static(__dirname + '/js'));
global.app.use(express.static(__dirname + '/images'));


var port = 10808;

http.createServer(global.app).listen(port);

log.logPrint(config.logLevel.INFO, 'web server started on port ' + port);
