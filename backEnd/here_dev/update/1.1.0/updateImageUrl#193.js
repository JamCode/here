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


            var updateSql = "update content_image_info set image_url = ?, image_compress_url = ? " +
            " where content_id = ? ";
            conn.executeSql(updateSql, [image_url, image_compress_url, item.content_id], function(flag, result){
                if(!flag){
                    console.log(result);
                }else{
                    console.log('update '+ item.content_id);
                }
            });
        });
    }else{
        console.log(result);
        conn.closePool();
    }
});
