//修改数据库中image url http到https

var conn = require('../../database/utility.js');


var sql = "select *from content_image_info";

conn.executeSql(sql, [], function(flag, result){
    if(flag){
        result.forEach(function(item){
            var image_url = item.image_url;
            var image_compress_url = item.image_compress_url;
            image_url = image_url.replace('http:', 'https:');
            image_compress_url = image_compress_url.replace('http:', 'https:');
            console.log(image_url);
            console.log(image_compress_url);
        });
    }else{
        console.log(result);
        conn.closePool();
    }
});
