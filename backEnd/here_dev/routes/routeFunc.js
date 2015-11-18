var log = global.log;
var config = require('../config/config');


exports.feedBack = function(flag, result, res, req) {

	var returnData = {};
	if (flag) {
		returnData.code = config.returnCode.SUCCESS;
		returnData.data = result;
	} else {
		log.error(result, log.getFileNameAndLineNum(__filename), req.body.sq);
		returnData.code = config.returnCode.ERROR;
		//email.sendMail(result);

	}
	log.debug(JSON.stringify(returnData), log.getFileNameAndLineNum(__filename),
		req.body.sq);
	res.send(returnData);
};
