var log = require('./utility/log');
log.SetLogFileName('logSchedule_');
global.log = log; // 设置全局
var fs = require('fs');

var schedule = require("node-schedule");
var pvCountRprt = require("./utility/staticRprt.js");
var path = require('path');
var email = require('./utility/emailTool');


var pidfile = path.join(process.env.HOME, '/schedule.pid');
fs.writeFileSync(pidfile, process.pid, {
    flag: 'w'
});


log.info("run schedule", log.getFileNameAndLineNum(__filename));

schedule.scheduleJob('57 23 * * *', function(){
    log.info("pv count start", log.getFileNameAndLineNum(__filename));
    pvCountRprt.start();
});



process.on('uncaughtException', function(err) {
    log.error('schedule process Caught exception: ' +
        err.stack);
    email.sendMail('schedule process Caught exception: ' + err.stack,
        'schedule process failed');
});
