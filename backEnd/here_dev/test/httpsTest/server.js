// var httpsModule = require('https');
// var fs = require('fs');
// var port = 4433;
// var https = httpsModule.Server({
//      key: fs.readFileSync('./server.key'),
//      cert: fs.readFileSync('./server.crt')
// }, function(req, res){
//     res.writeHead(200);
//     res.end("hello world\n");
// });
//
// https.listen(port, function(err){
//      console.log("https listening on port: "+port);
// });

var express = require('express');
var https = require('https');
var fs = require('fs');
var port1 = 4433;
var app = express();

var options = {
  key: fs.readFileSync('./server.key'),
  cert: fs.readFileSync('./server.crt')
};

https.createServer(options, app).listen(port1);


var http = require('http');
var port2 = 8080;
var server = http.createServer(app);
server.listen(port2);

app.get('/', function(req, res){
    res.send('hello world');
});
