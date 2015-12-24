#181
create or replace view image_url_v
    as
    select `b`.`content_id` AS `content_id`,
       `b`.`image_url` AS `image_url`,
       `b`.`image_compress_url` AS `image_compress_url`,
       `a`.`user_id` AS `user_id`,
       `a`.`content_publish_timestamp` AS `timestamp`
  from(`content_base_info` `a` join `content_image_info` `b`)
 where(`a`.`content_id`= `b`.`content_id` and `a`.anonymous <> 1);
