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
