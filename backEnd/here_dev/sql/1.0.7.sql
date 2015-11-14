#111
DROP TABLE IF EXISTS  `daliy_report`;
CREATE TABLE `daliy_report` (
  `pv_count` int(11) NOT NULL,
  `uv_count` int(11) NOT NULL,
  `timestamp` bigint  NOT NULL,
  `date` varchar(20)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

#129
ALTER TABLE `user_base_info` ADD UNIQUE KEY `user_name`(`user_name`) USING BTREE

#94
ALTER TABLE `user_base_info`
	MODIFY COLUMN `user_facethumbnail` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci NULL AFTER `user_password`,
	MODIFY COLUMN `user_face_image` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci NULL AFTER `user_facethumbnail`,
	MODIFY COLUMN `user_age` int(11) NULL AFTER `user_face_image`,
	MODIFY COLUMN `user_gender` int(11) NULL AFTER `user_age`;

#94
ALTER TABLE `user_base_info`
    MODIFY COLUMN `user_certificated_process` int(11) NULL AFTER `user_introduce`;
