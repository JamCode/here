var path = require('path');
var config = require('../config/config');
var global_config = null;

if (process.env.ENV === 'dev') {
    global_config = require('../config/dev_env_config');
}

if (process.env.ENV === 'pro') {
    global_config = require('../config/pro_env_config');
}

var log4js = require('log4js');
var logger;

exports.SetLogFileName = function(fileName) {

    var fullpath = fileName;
    if(global_config==null){

    }else{
        fullpath = path.join(global_config.env.homedir,
            'logs', fileName);
    }


    log4js.configure({
        appenders: [{
            type: 'console'
        }, {
            type: 'dateFile',
            absolute: true,
            filename: fullpath,
            maxLogSize: 1024 * 1024,
            backups: 4,
            pattern: 'yyyy-MM-dd.log',
            alwaysIncludePattern: true,
            category: 'normal'
        }],
        replaceConsole: true
    });

    logger = log4js.getLogger('normal');

    // 配置日志打印级别，低于此级别的不打印
    logger.setLevel('DEBUG');
};

exports.getFileNameAndLineNum = function(fullfilename) {
    // console.log('enter getFileNameAndLineNum');
    try {
        throw new Error('get file name and line number');
        // console.log('throw exception');
    } catch (err) {
        var filename = fullfilename.substr(fullfilename.lastIndexOf('/'));
        var stackArr = err.stack.split('\n');
        // console.log(err.stack);
        if (stackArr.length < 3) {
            return filename;
        }

        var msg = stackArr[2].substr(stackArr[2].lastIndexOf(filename) + 1,
            stackArr[2].length - stackArr[2].lastIndexOf(filename) - 2);

        return msg;
    }
};

exports.info = function(info, fileNameLineNum, sq) {
    if (sq != null) {
        logger.info('[' + sq + '] - ' + fileNameLineNum + ' ' + info);
    } else {
        logger.info(fileNameLineNum + ' ' + info);
    }
};

exports.debug = function(info, fileNameLineNum, sq) {
    if(process.env.ENV === 'dev'){
        if (sq != null) {
            logger.debug('[' + sq + '] - ' + fileNameLineNum + ' ' + info);
        } else {
            logger.debug(fileNameLineNum + ' ' + info);
        }
    }
};

exports.error = function(info, fileNameLineNum, sq) {
    if (sq != null) {
        logger.error('[' + sq + '] - ' + fileNameLineNum + ' ' + info);
    } else {
        logger.error(fileNameLineNum + ' ' + info);
    }
};

exports.warn = function(info, fileNameLineNum, sq) {
    if (sq != null) {
        logger.warn('[' + sq + '] - ' + fileNameLineNum + ' ' + info);
    } else {
        logger.warn(fileNameLineNum + ' ' + info);
    }
};

exports.logPrint = function(level, info) {

    if (level === config.logLevel.DEBUG) {
        logger.debug(info);
    } else if (level === config.logLevel.INFO) {
        logger.info(info);
    } else if (level === config.logLevel.WARN) {
        logger.warn(info);
    } else if (level === config.logLevel.ERROR) {
        logger.error(info);
    } else if (level === config.logLevel.FATAL) {
        logger.fatal(info);
    }
};
