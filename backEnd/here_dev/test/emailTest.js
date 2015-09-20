
console.log('prepare for sending email');

var nodemailer = require('nodemailer');

var smtpTrans = nodemailer.createTransport( 
{
	service: '163',
	auth: {
	    user: "wh85125@163.com", // 账号
	    pass: "wohouhui" // 密码
  	}
  	//port: 456,
  	//host: 'smtp.163.com',
  	//secure: true
});

// 设置邮件内容
var mailOptions = {
  from: "wh85125@163.com", // 发件地址
  to: "wh85125@163.com", // 收件列表
  subject: "系统报警", // 标题
  text: "hello" // html 内容
};

console.log('prepare for sending email');

smtpTrans.sendMail(mailOptions, function(err, info){
	if (err) {
		console.log(err);
	}else{
		console.log('message sent:'+info.response);
	}
});