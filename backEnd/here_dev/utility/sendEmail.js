// using for send email
// parameter should be subject and text

var email = require('./emailTool');

if (process.argv.length !== 4) {
	console.log('parameter shoule be included subject and file');
	process.exit();
}

var subject = process.argv[2];
var filepath = process.argv[3];

var rf = require('fs');
var data = rf.readFileSync(filepath, 'utf-8');
console.log(data);

email.sendMail(data, subject);
