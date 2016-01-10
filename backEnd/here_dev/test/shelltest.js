var shell = require('shelljs');
var path = require('path');

shell.cd(path.join(process.env.HOME,
    'logs'));

shell.ls('access*.log').forEach(function(file){
    console.log(file);
});
