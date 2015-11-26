var path = require('path');
var LineReader = require('line-reader');
var conn = require('../database/utility.js');
var emailTool = require('./emailTool');
var log = global.log;


function getDate() {
    var date = new Date();
    var y = date.getFullYear();
    var M = "0" + (date.getMonth() + 1);
    M = M.substring(M.length - 2);
    var d = "0" + date.getDate();
    d = d.substring(d.length - 2);
    var curDateStr = y + M + d;
    return curDateStr;
}

function InsertToDatabase(pvCount, uvCount) {
    var sql =
        "insert into daliy_report(pv_count,uv_count,timestamp,date)values(?,?,?,?)";
    var timestamp = Date.now() / 1000;
    var curDateStr = new Date();

    //console.log('read a file done.');
    conn.executeSql(sql, [pvCount, uvCount, timestamp, curDateStr],
        function(flag, result) {
            if (flag) {
                log.info("insert pvcount OK", log.getFileNameAndLineNum(__filename));
            } else {
                log.error(result, log.getFileNameAndLineNum(__filename));
            }
        });
}

function generateReportEmail(pvCount, uvCount) {
    //create rprtLog file
    var curDateStr = getDate();
    var todayRprt = curDateStr + "-----[pvCount :" + pvCount +
        ";uvCount:" + uvCount + "]";
    emailTool.sendMail(todayRprt, curDateStr + "_访问量统计");
}

function daliyRprt(logPath) {
    var pvCount = 0;
    var uvCount = 0;
    var uvMap = {};
    LineReader.eachLine(logPath, function(line, last) {
        ++pvCount;
        var lineStr = line.toString();
        var obj = [];
        obj = lineStr.split(" ");
        if (uvMap[obj[0].trim()] == null) {
            uvCount++;
            uvMap[obj[0].trim()] = 1;
        }

        //this is last line
        if (last === true) {
            InsertToDatabase(pvCount, uvCount);
            generateReportEmail(pvCount, uvCount);
            return false;
        }
    });
}

exports.start = function(){
    var logPath = path.join(process.env.HOME,
        'logs', 'access_%DATE%.log');
    daliyRprt(logPath);
};
