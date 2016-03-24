var crypto = require('crypto');

var password = crypto.createHash('sha384').update('madaxiao', 'utf8').digest();
console.log(password);
var key = new Buffer('280f8bb8c43d532f389ef0e2a5321220b0782b065205dcdfcb8d8f02ed5115b9');
var iv = new Buffer('CC0A69779E15780ADAE46C45EB451A23');
// password.copy(key, 0, 0, 32);
// password.copy(iv, 0, 32, 16);
// console.log(key);
// console.log(iv);
// console.log(password);

var decipher = crypto.createDecipheriv('aes256', key,
iv);
var encrypted = 'WQYg5qvcGyCBY3IF0hPsoQ==';
var decrypted = decipher.update(encrypted, 'base64', 'utf8');
decrypted += decipher.final('utf8');
console.log(decrypted);


// var crypto = require('crypto');
// var cipher = crypto.createCipher('aes256', 'madaxiao');
//
// var encrypted = cipher.update('abc');
// encrypted += cipher.final('base64');
// console.log(encrypted);
