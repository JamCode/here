//using for send email
//parameter should be subject and text

var email = require('./emailTool');


if(process.argv.length!=4){
	console.log('parameter shoule be included subject and text');
	return;
}

var subject = process.argv[2];
var text = process.argv[3];

email.sendMail(text, subject);
