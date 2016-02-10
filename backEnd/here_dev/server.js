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
var contentRouter = require('./routes/contentRouter.js');
var userRouter = require('./routes/userRouter.js');

var image = require('./routes/image.js');
var config = require('./config/config');

var cluster = require('cluster');
var port1 = global_config.httpServerInfo.listen_port;
var email = require('./utility/emailTool');

var fs = require('fs');
var morgan = require('morgan');
var fileStreamRotator = require('file-stream-rotator');


if (cluster.isMaster) {
	// require('os').cpus().forEach(function(){
	//    	cluster.fork();
	//  	});

	// write pid to app.pid
	var pidfile = path.join(global_config.env.homedir, '/webServer.pid');
	fs.writeFileSync(pidfile, process.pid, {
		flag: 'w'
	});

	process.on('uncaughtException', function(err) {
		log.logPrint(config.logLevel.ERROR, 'master HTTP SERVER Caught exception: ' +
			err.stack);
		email.sendMail('HTTP SERVER Caught exception: ' + err.stack,
			'server process failed');
	});

	cluster.fork();
	cluster.on('exit', function(worker, code, signal) {
		log.logPrint(config.logLevel.ERROR, 'server worker ' + worker.process.pid +
			' died, code is ' + code + ', signal is ' + signal);
		cluster.fork();
		// send msg to admin
		email.sendMail('server worker ' + worker.process.pid + ' died',
			'server process failed');
	});

	cluster.on('listening', function(worker, address) {
		log.logPrint(config.logLevel.INFO, 'A server worker with pid#' + worker.process
			.pid + ' is now listening to:' + address.port);
	});
} else {

	startHTTPServer(port1);
}

function startHTTPServer(port) {

	process.on('uncaughtException', function(err) {
		log.error('slaver HTTP SERVER Caught exception: ' + err.stack, log.getFileNameAndLineNum(
			__filename));
		email.sendMail('HTTP SERVER Caught exception: ' + err.stack,
			'server process failed');
	});
	global.app = express(); // 创建express实例

	// view engine setup
	global.app.set('views', path.join(__dirname, 'views'));
	global.app.set('view engine', 'ejs');
	global.app.set('imagePath', path.join(__dirname, 'images'));

	global.app.use(bodyParser.json());
	global.app.use(bodyParser.urlencoded({
		extended: false
	}));

	// create a rotating write stream
	var accessLogStream = fileStreamRotator.getStream({
  		filename: path.join(global_config.env.homedir,
			'logs', '/access_%DATE%.log'),
  		frequency: 'daily',
  		verbose: false,
		date_format: "YYYY-MM-DD"
	});

	global.app.use(morgan('short', {
		stream: accessLogStream
	}));

	// 该路由使用的中间件
	global.app.use(function(req, res, next) {
		req.body.sq = Date.now();
		log.info(JSON.stringify(req.body), log.getFileNameAndLineNum(__filename),
			req.body.sq);
		next();
	});

	global.app.use('/', contentRouter);
	global.app.use('/', userRouter);
	global.app.use('/image', image);

	global.app.use(express.static(__dirname + '/css'));
	global.app.use(express.static(__dirname + '/js'));
	global.app.use(express.static(__dirname + '/images'));


	// var options = {
	//   key: fs.readFileSync(__dirname + '/key/server.key'),
	//   cert: fs.readFileSync(__dirname + '/key/server.crt')
	// };

	http.createServer(global.app).listen(port);

	log.logPrint(config.logLevel.INFO, 'Express started on port ' + port);
}
