var crypto = require('crypto');

var password = crypto.createHash('sha384').update('madaxiao', 'utf8').digest();
console.log(password);
var key = new Buffer(32);
var iv = new Buffer(16);
password.copy(key, 0, 0, 32);
password.copy(iv, 0, 32, 16);
console.log(key);
console.log(iv);
console.log(password);

var decipher = crypto.createDecipheriv('aes128', key, iv);
var encrypted = 'Wj6zUKv3us9kwKaaYR+8Bg==';
var decrypted = decipher.update(encrypted, 'base64', 'utf8');
decrypted += decipher.final('utf8');
console.log(decrypted);


// var crypto = require('crypto');
// var cipher = crypto.createCipher('aes256', 'madaxiao');
//
// var encrypted = cipher.update('abc');
// encrypted += cipher.final('base64');
// console.log(encrypted);
