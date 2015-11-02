#111
DROP TABLE IF EXISTS  `daily_report`;
CREATE TABLE `daily_report` (
  `pv_count` int(11) NOT NULL,
  `uv_count` int(11) NOT NULL,
  `timestamp` bigint,
  `date` varchar(30)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
