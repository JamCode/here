var http = require('http');
var global_config;
if (process.env.ENV === 'dev') {
    global_config = require('../../config/dev_env_config');
}
if (process.env.ENV === 'pro') {
    global_config = require('../../config/pro_env_config');
}
var hostname = '112.74.102.178';


var commentGoodJson = {
    childpath: '/commentGood',
    content_comment_id: 'commentGoodtest',
    user_id: 'commentGoodtest',
    comment_user_id: 'commentGoodtest',
    user_name: 'commentGoodtest'
};

var options = {
    port: global_config.httpServerInfo.listen_port,
    hostname: hostname,
    method: 'POST',
    path: commentGoodJson.childpath,
    headers: {
        'Content-Type': 'application/json; encoding=utf-8',
        'Accept': 'application/json',
        'Content-Length': JSON.stringify(commentGoodJson).length
    }
};

var body = '';

var req = http.request(options, function(res) {
    console.log("Got response: " + res.statusCode);
    res.on('data', function(d) {
        body += d;
    }).on('end', function() {
        console.log(res.headers);
        console.log(body);
    });
}).on('error', function(e) {
    console.log("Got error: " + e.message);
});

req.write(JSON.stringify(commentGoodJson)+"\n");
req.end();
