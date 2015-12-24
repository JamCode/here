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

var http = require('http');
var port = 4433;
var server = http.createServer(function(req, res){
    res.end('hello world\n');
});
server.listen(port);
