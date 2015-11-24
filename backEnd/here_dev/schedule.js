var log = require('./utility/log');
log.SetLogFileName('logSchedule_');
global.log = log; // 设置全局

var schedule = require("node-schedule");
var pvCountRprt = require("./utility/staticRprt.js");


schedule.scheduleJob('*/1 * * * *', function(){
    pvCountRprt.start();
    console.log('pv count start');
});
