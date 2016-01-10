var http = require('http');

var hostname = '112.74.102.178';

exports.runTest = function(jsonObject, childpath){
    var options = {
        port: 8080,
        hostname: hostname,
        method: 'POST',
        path: childpath,
        headers: {
            'Content-Type': 'application/json; encoding=utf-8',
            'Accept': 'application/json',
            'Content-Length': JSON.stringify(jsonObject).length
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

    req.write(JSON.stringify(jsonObject));
    req.end();
};
