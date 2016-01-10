var log = global.log;

exports.encode = function (str) {

	log.debug(str, log.getFileNameAndLineNum(__filename));

	var encodeStr = new Buffer(str);
	encodeStr = encodeStr.toString('base64');
	log.debug(encodeStr, log.getFileNameAndLineNum(__filename));
	return encodeStr;
};

exports.decode = function (str) {

	log.debug(str, log.getFileNameAndLineNum(__filename));

	var decodeStr = new Buffer(str, 'base64');
	decodeStr = decodeStr.toString();
	log.debug(decodeStr, log.getFileNameAndLineNum(__filename));

	return decodeStr;
};
