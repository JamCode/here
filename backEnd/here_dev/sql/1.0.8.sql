#147
CREATE TABLE `comment_good_base_info` (
	`content_comment_id` varchar(100) NOT NULL,
	`user_id` varchar(100) NOT NULL,
	PRIMARY KEY (`content_comment_id`,`user_id`)
) ENGINE=InnoDB;
ALTER TABLE `content_comment_info`
	ADD COLUMN `good_count` int(11) NOT NULL DEFAULT 0 AFTER `to_content`;
ALTER TABLE `content_comment_info`
	CHANGE COLUMN `good_count` `comment_good_count` int(11) NOT NULL DEFAULT 0

ALTER TABLE `comment_good_base_info`
	ADD COLUMN `cgbi_timestamp` bigint(20) NULL

#169
ALTER TABLE `content_base_info`
	ADD COLUMN `content_report` int(32) NOT NULL DEFAULT 0


#171
CREATE TABLE `user_follow_base_info` (
		`user_id` varchar(100) NOT NULL,
		`followed_user_id` varchar(100) NOT NULL,
		`follow_timestamp` bigint NOT NULL,
		PRIMARY KEY (`user_id`,`followed_user_id`)
	) ENGINE=InnoDB;

#171
ALTER TABLE `user_base_info`
	MODIFY COLUMN `user_fans_count` int(11) NOT NULL DEFAULT 0 AFTER `certificate_id`,
	MODIFY COLUMN `user_follow_count` int(11) NOT NULL DEFAULT 0 AFTER `user_fans_count`;

#171
	DROP VIEW IF EXISTS `user_content_count_v`;
	CREATE VIEW `user_content_count_v` AS
	select COUNT(*) as content_count, user_id from `content_base_info`  GROUP BY `user_id`
