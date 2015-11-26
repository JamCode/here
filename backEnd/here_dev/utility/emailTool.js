var nodemailer = require('nodemailer');

var log = global.log;

var smtpTrans = nodemailer.createTransport(
{
	service: '163',
	auth: {
		user: 'wh851125@163.com', // 账号
		pass: '851125' // 密码
	}
  // port: 456,
  // host: 'smtp.163.com',
  // secure: true
});

exports.sendMail = function (text, emailSubject) {
	// 设置邮件内容
	var mailOptions = {
		from: 'wh851125@163.com', // 发件地址
		to: '23766856@qq.com', // 收件列表
		subject: emailSubject, // 标题
		text: text // html 内容
	};

	smtpTrans.sendMail(mailOptions, function (err, info) {
		if (err) {
			console.log(err);
			if(log!=null){
				log.error(err, log.getFileNameAndLineNum(__filename));
			}
		}else {
			console.log('message sent:' + info.response);
			if(log!=null){
				log.info('message sent:' + info.response, log.getFileNameAndLineNum(__filename));
			}
		}
	});
};
