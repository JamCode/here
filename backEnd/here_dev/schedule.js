var log = require('./utility/log');
log.SetLogFileName('logSchedule_');
global.log = log; // 设置全局
var fs = require('fs');
require('shelljs/global');
var schedule = require("node-schedule");
var pvCountRprt = require("./utility/staticRprt.js");
var path = require('path');
var email = require('./utility/emailTool');
var child_process = require('child_process');

var pidfile = path.join(process.env.HOME, '/schedule.pid');
fs.writeFileSync(pidfile, process.pid, {
    flag: 'w'
});


log.info("run schedule", log.getFileNameAndLineNum(__filename));



//统计pv和upv
schedule.scheduleJob('57 23 * * *', function(){
    log.info("pv count start", log.getFileNameAndLineNum(__filename));
    pvCountRprt.start();
});


//文件系统报告
schedule.scheduleJob('59 23 * * *', function(){
    log.info("file system report start", log.getFileNameAndLineNum(__filename));
    child_process.execFile(__dirname + '/sh_script/sysReport.pl', null, {}, function(err, stdout, stderr){
        if(err!=null){
            log.error(err, log.getFileNameAndLineNum(__filename));
        }else{
            log.info("file system report finish", log.getFileNameAndLineNum(__filename));
        }
    });
});

//日志错误统计
schedule.scheduleJob('58 23 * * *', function(){
    log.info("errorLogReport start", log.getFileNameAndLineNum(__filename));
    child_process.execFile(__dirname + '/sh_script/errorLogReport.pl', null, {}, function(err, stdout, stderr){
        if(err!=null){
            log.error(err, log.getFileNameAndLineNum(__filename));
        }else{
            log.info("errorLogReport finish", log.getFileNameAndLineNum(__filename));
        }
    });
});

//日志压缩备份
schedule.scheduleJob('59 23 * * *', function(){
    log.info("zipHereLog start", log.getFileNameAndLineNum(__filename));
    child_process.execFile(__dirname + '/sh_script/zipHereLog.sh', null, {}, function(err, stdout, stderr){
        if(err!=null){
            log.error(err, log.getFileNameAndLineNum(__filename));
        }else{
            log.info("zipHereLog finish", log.getFileNameAndLineNum(__filename));
        }
    });
});



process.on('uncaughtException', function(err) {
    log.error('schedule process Caught exception: ' +
        err.stack);
    email.sendMail('schedule process Caught exception: ' + err.stack,
        'schedule process failed');
});
