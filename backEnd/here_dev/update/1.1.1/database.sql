#205
UPDATE `content_base_info` set `content_image_url` = REPLACE (content_image_url, 'http', 'https');


#211
UPDATE `content_base_info` set `content_image_url` = REPLACE (content_image_url, 'https', 'http');
UPDATE `content_image_info` SET `image_url` =REPLACE (`image_url`, 'https', 'http');
UPDATE `content_image_info` SET `image_compress_url` =REPLACE (`image_compress_url`, 'https', 'http');
UPDATE `user_base_info` SET `user_facethumbnail` = REPLACE (`user_facethumbnail`, 'https', 'http');
UPDATE `user_base_info` SET `user_face_image` = REPLACE (`user_face_image`, 'https', 'http');
