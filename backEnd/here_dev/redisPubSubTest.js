


var redis = require("redis");
var client1 = redis.createClient();

client1.subscribe("aaa");


client1.on("subscribe", function (channel, count) {
	console.log("channel "+channel+" count "+count);
});


client1.on("message", function (channel, message) {
   	console.log("channel "+channel+" "+message);
});