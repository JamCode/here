var nodemailer = require('nodemailer');

var smtpTrans = nodemailer.createTransport( 
{
	service: '163',
	auth: {
	    user: "wh85125@163.com", // 账号
	    pass: "iwillbeok" // 密码
  	}
  	//port: 456,
  	//host: 'smtp.163.com',
  	//secure: true
});

exports.sendMail = function(text){
	// 设置邮件内容
	var mailOptions = {
	  from: "wh85125@163.com", // 发件地址
	  to: "wh85125@163.com", // 收件列表
	  subject: "系统报错", // 标题
	  text: text // html 内容
	};

	smtpTrans.sendMail(mailOptions, function(err, info){
		if (err) {
			console.log(err);
		}else{
			console.log('message sent:'+info.response);
		}
	});
}


