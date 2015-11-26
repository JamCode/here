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