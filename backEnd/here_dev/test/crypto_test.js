// var crypto = require('crypto');
// var decipher = crypto.createDecipher('aes192', 'madaxiao');
// var encrypted = '2SJLISHll2cBmjY2lrTvXA==';
// var decrypted = decipher.update(encrypted, 'base64', 'utf8');
// decrypted += decipher.final('utf8');
// console.log(decrypted);


var crypto = require('crypto');
var cipher = crypto.createCipher('aes256', 'madaxiao');

var encrypted = cipher.update('abc', 'utf8', 'base64');
encrypted += cipher.final('base64');
console.log(encrypted);
