var querystring = require('querystring');
var http = require('http');
var request = require('request');
var config = require('../config/config');


exports.sendMessage = function(userPhone, confirmCode, callback){
	var postData = {
 	    uid: config.weimi.uid,
 	    pas: config.weimi.pas,
  	  mob: userPhone,
  	  cid: config.weimi.cid,
  	  p1: confirmCode,
  	  type: 'json'
	};

	var content = querystring.stringify(postData);

	var options = {
    	host: config.weimi.host,
  		path: config.weimi.sendUrl,
    	method: 'POST',
    	agent: false,
    	rejectUnauthorized: false,
    	headers: {
        	'Content-Type' : 'application/x-www-form-urlencoded', 
        	'Content-Length' :content.length
    	}
	};
	
	var req = http.request(options,function(res){
  		res.setEncoding('utf8');
    	res.on('data', function (chunk) {
        	callback(JSON.parse(chunk));
    	});
	});
	req.write(content);
	req.end();
}
