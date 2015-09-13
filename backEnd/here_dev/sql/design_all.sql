SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS  `confirm_phone`;
CREATE TABLE `confirm_phone` (
  `user_phone` varchar(100) NOT NULL,
  `certificate_code` varchar(100) NOT NULL,
  `time_stamp` bigint(20) NOT NULL,
  PRIMARY KEY (`user_phone`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS  `content_base_info`;
CREATE TABLE `content_base_info` (
  `content_id` varchar(100) NOT NULL,
  `user_id` varchar(100) NOT NULL,
  `content` varchar(512) NOT NULL,
  `content_publish_latitude` float NOT NULL,
  `content_publish_longitude` float NOT NULL,
  `content_see_count` int(11) NOT NULL,
  `content_comment_count` int(11) NOT NULL,
  `content_publish_timestamp` bigint(20) NOT NULL,
  `anonymous` int(11) NOT NULL,
  `content_image_url` varchar(200) DEFAULT NULL,
  `content_good_count` int(11) NOT NULL,
  `address` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`content_id`),
  KEY `User_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS  `content_comment_info`;
CREATE TABLE `content_comment_info` (
  `content_comment_id` varchar(100) NOT NULL,
  `content_id` varchar(100) NOT NULL,
  `comment_user_id` varchar(100) NOT NULL,
  `comment_to_user_id` varchar(100) NOT NULL,
  `comment_content` varchar(1000) NOT NULL,
  `comment_timestamp` bigint(20) NOT NULL,
  `to_content` int(11) NOT NULL DEFAULT '1' COMMENT '评论内容的',
  PRIMARY KEY (`content_comment_id`),
  KEY `content_id` (`content_id`),
  KEY `comment_user_id` (`comment_user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS  `content_image_info`;
CREATE TABLE `content_image_info` (
  `image_id` varchar(100) NOT NULL,
  `content_id` varchar(100) NOT NULL,
  `image_url` varchar(100) NOT NULL,
  PRIMARY KEY (`image_id`),
  UNIQUE KEY `content_id` (`content_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS  `content_location_info`;
CREATE TABLE `content_location_info` (
  `content_id` varchar(100) NOT NULL,
  `content_publish_latitude` float NOT NULL,
  `content_publish_longitude` float NOT NULL,
  `city_desc` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS  `device_notify_count`;
CREATE TABLE `device_notify_count` (
  `device_token` varchar(200) NOT NULL,
  `count` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS  `get_missed_msg_record`;
CREATE TABLE `get_missed_msg_record` (
  `user_id` varchar(100) NOT NULL,
  `last_timestamp` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS  `good_base_info`;
CREATE TABLE `good_base_info` (
  `user_id` varchar(100) NOT NULL,
  `content_id` varchar(100) NOT NULL,
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS  `private_message_info`;
CREATE TABLE `private_message_info` (
  `msg_id` varchar(100) CHARACTER SET utf8 NOT NULL COMMENT '后台编码',
  `msg_srno` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '客户端编码',
  `sender_user_id` varchar(100) CHARACTER SET utf8 NOT NULL,
  `receive_user_id` varchar(100) CHARACTER SET utf8 NOT NULL,
  `message_content` varchar(1000) COLLATE utf8mb4_unicode_ci NOT NULL,
  `send_timestamp` bigint(20) NOT NULL,
  `msg_type` int(11) DEFAULT NULL,
  `datapath` varchar(200) CHARACTER SET utf8mb4 DEFAULT NULL,
  `voice_time` int(32) NOT NULL DEFAULT '0',
  PRIMARY KEY (`msg_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS  `user_base_info`;
CREATE TABLE `user_base_info` (
  `user_id` varchar(100) NOT NULL,
  `user_phone` varchar(100) NOT NULL,
  `user_name` varchar(100) NOT NULL,
  `user_password` varchar(100) NOT NULL,
  `user_facethumbnail` varchar(200) NOT NULL,
  `user_age` int(11) NOT NULL,
  `user_gender` int(11) NOT NULL,
  `user_career` varchar(100) DEFAULT '',
  `user_company` varchar(100) DEFAULT '',
  `user_sign` varchar(100) DEFAULT ' ',
  `user_interest` varchar(100) DEFAULT '',
  `user_introduce` varchar(200) DEFAULT '',
  `user_certificated_process` int(11) NOT NULL,
  `certificate_id` varchar(100) DEFAULT '',
  `user_fans_count` int(11) NOT NULL,
  `user_follow_count` int(11) NOT NULL,
  `device_token` varchar(100) NOT NULL,
  `is_logout` int(11) NOT NULL,
  `user_background_image_url` varchar(100) DEFAULT NULL,
  `user_birth_day` varchar(32) DEFAULT NULL,
  `good_count` int(11) DEFAULT '0',
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `User_email` (`user_phone`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS  `user_black_list`;
CREATE TABLE `user_black_list` (
  `user_id` varchar(100) NOT NULL,
  `counter_user_id` varchar(100) NOT NULL,
  `timestamp` bigint(20) NOT NULL,
  PRIMARY KEY (`user_id`,`counter_user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS  `user_collect_list`;
CREATE TABLE `user_collect_list` (
  `user_id` varchar(100) NOT NULL,
  `content_id` varchar(100) NOT NULL,
  `timestamp` bigint(20) NOT NULL,
  PRIMARY KEY (`user_id`,`content_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS  `user_image_info`;
CREATE TABLE `user_image_info` (
  `user_id` varchar(100) NOT NULL,
  `user_image_url` varchar(100) NOT NULL,
  `time_stamp` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS  `user_location_info`;
CREATE TABLE `user_location_info` (
  `user_id` varchar(100) NOT NULL,
  `location_latitude` float DEFAULT NULL,
  `location_longitude` float DEFAULT NULL,
  `refresh_timestamp` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`user_id`),
  CONSTRAINT `user_location_info_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user_base_info` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS  `visit_record`;
CREATE TABLE `visit_record` (
  `user_id` varchar(100) NOT NULL,
  `visit_user_id` varchar(100) NOT NULL,
  `visit_timestamp` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

SET FOREIGN_KEY_CHECKS = 1;

/* VIEWS */;

DROP VIEW IF EXISTS `image_url_v`;
CREATE VIEW `image_url_v` AS
SELECT `user_image_info`.`user_id` AS `user_id`,
       `user_image_info`.`user_image_url` AS `user_image_url`,
       `user_image_info`.`time_stamp` AS `time_stamp`
FROM `user_image_info`
UNION
SELECT `content_base_info`.`user_id` AS `user_id`,
       `content_base_info`.`content_image_url` AS `user_image_url`,
       (`content_base_info`.`content_publish_timestamp` * 1000) AS `time_stamp`
FROM `content_base_info`
WHERE ((`content_base_info`.`content_image_url` <> '')
       AND (`content_base_info`.`anonymous` <> 1));


DROP VIEW IF EXISTS `user_city_count_v`;
CREATE VIEW `user_city_count_v` AS
SELECT `c`.`user_id` AS `user_id`,
       count(DISTINCT `a`.`city_desc`) AS `city_visit_count`
FROM ((`content_location_info` `a`
       JOIN `content_base_info` `b`)
      JOIN `user_base_info` `c`)
WHERE ((`a`.`content_id` = `b`.`content_id`)
       AND (`b`.`user_id` = `c`.`user_id`));



DROP VIEW IF EXISTS `user_token_v`;
CREATE VIEW `user_token_v` AS
SELECT `a`.`user_id` AS `user_id`,
       `b`.`device_token` AS `device_token`,
       `b`.`count` AS `count`
FROM (`user_base_info` `a`
      JOIN `device_notify_count` `b`)
WHERE (`a`.`device_token` = `b`.`device_token`);

 


