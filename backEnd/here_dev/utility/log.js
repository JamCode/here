/**
 * @author wang jam
 * add log module
 * 20141009
 */
var path = require('path');
var config = require('../config/config');
var global_config = require('../config/env_config');
var log4js = require('log4js');
var logger;

exports.SetLogFileName = function(fileName){
    log4js.configure({
        appenders: [{
            type: 'console'
        }, {
            type: 'dateFile',
            absolute: true,
            filename: path.join(global_config.env.homedir, 'logs', fileName),
            maxLogSize: 1024 * 1024,
            backups: 4,
            pattern: "yyyy-MM-dd.log",
            alwaysIncludePattern: true,
            category: 'normal'
        }],
        replaceConsole: true
    });

    logger = log4js.getLogger('normal');
    logger.setLevel('DEBUG'); //配置日志打印级别，低于此级别的不打印
}


exports.getFileNameAndLineNum = function(fullfilename){
    //console.log('enter getFileNameAndLineNum');
    try{
        throw new Error('get file name and line number');
        //console.log('throw exception');

    }catch(err){

        //console.log(fullfilename);

        var filename = fullfilename.substr(fullfilename.lastIndexOf('/'));
        
        var stackArr = err.stack.split("\n");
        //console.log(err.stack);

        if(stackArr.length<3){
            return filename;
        }

        var msg = stackArr[2].substr(stackArr[2].lastIndexOf(filename)+1, 
            stackArr[2].length - stackArr[2].lastIndexOf(filename)-2);

        //console.log(err.stack);
        //console.log(msg);

        return msg;
    }
    //console.log('exit getFileNameAndLineNum');

}

exports.info = function(info, fileNameLineNum) {
    logger.info(fileNameLineNum+" "+info);
}

exports.debug = function(info, fileNameLineNum) {
    logger.debug(fileNameLineNum+" "+info);
}

exports.error = function(info, fileNameLineNum) {
    logger.error(fileNameLineNum+" "+info);
}

exports.warn = function(info, fileNameLineNum) {
    logger.warn(fileNameLineNum+" "+info);
}

exports.logPrint = function(level, info) {

    if (level == config.logLevel.DEBUG) {
        logger.debug(info);
    } else if (level == config.logLevel.INFO) {
        logger.info(info);
    } else if (level == config.logLevel.WARN) {
        logger.warn(info);
    } else if (level == config.logLevel.ERROR) {
        logger.error(info);
    } else if (level == config.logLevel.FATAL) {
        logger.fatal(info);
    }
}


function getNowFormatDate() {
    var date = new Date();
    var seperator1 = "-";
    var seperator2 = ":";
    var month = date.getMonth() + 1;
    var strDate = date.getDate();
    var hour = date.getHours();
    var min = date.getMinutes();
    var sec = date.getSeconds();

    if (month >= 1 && month <= 9) {
        month = "0" + month;
    }
    if (strDate >= 0 && strDate <= 9) {
        strDate = "0" + strDate;
    }
    if (min < 10) {
        min = "0" + min;
    }
    if (hour < 10) {
        hour = "0" + hour;
    }
    if (sec < 10) {
        sec = "0" + sec;
    }

    var currentdate = date.getFullYear() + seperator1 + month + seperator1 + strDate + " " + hour + seperator2 + min + seperator2 + sec;
    return currentdate;
}
