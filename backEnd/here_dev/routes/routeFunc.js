var log = global.log;
var config = require('../config/config');


exports.feedBack = function(flag, result, res, sq) {

	var returnData = {};
	if (flag) {
		returnData.code = config.returnCode.SUCCESS;
		returnData.data = result;
	} else {
		log.error(result, log.getFileNameAndLineNum(__filename), sq);
		returnData.code = config.returnCode.ERROR;
		//email.sendMail(result);

	}
	log.debug(JSON.stringify(returnData), log.getFileNameAndLineNum(__filename),
		sq);
	res.send(returnData);
};
