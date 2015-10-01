
DROP TABLE IF EXISTS  `content_image_info`;
CREATE TABLE `content_image_info` (
  `content_id` varchar(100) NOT NULL,
  `image_url` varchar(200) NOT NULL,
  `image_compress_url` varchar(200) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


ALTER TABLE `user_base_info` add column `user_face_image` varchar(200) NOT NULL after `user_facethumbnail`;


ALTER TABLE `content_base_info` add column `content_publish_date` varchar(20) NOT NULL after `content_publish_timestamp`;

ALTER TABLE `good_base_info` drop primary key;

ALTER TABLE `good_base_info` add column `gbi_timestamp` bigint(20) NOT NULL after `content_id`;


drop view if EXISTS `image_url_v`;
CREATE VIEW `image_url_v` AS
select b.*, a.user_id, a.content_publish_timestamp as timestamp from content_base_info a, content_image_info b
where a.content_id = b.content_id;


DROP TABLE IF EXISTS  `content_report_info`;
CREATE TABLE `content_report_info` (
  `cri_content_id` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS  `feedback_info`;
CREATE TABLE `feedback_info` (
  `fi_user_id` varchar(100) NOT NULL,
  `fi_feedback` varchar(300),
  `submit_timestamp` bigint(20)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;