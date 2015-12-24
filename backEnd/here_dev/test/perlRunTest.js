
var child_process = require('child_process');
child_process.execFile('../sh_script/sysReport.pl', null, {}, function(err, stdout, stderr){
    if(err!=null){
        console.log(err);
    }else{
        console.log("test finish");
    }
});
