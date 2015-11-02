#111
DROP TABLE IF EXISTS  `daliy_report`;
CREATE TABLE `daliy_report` (
  `pv_count` int(11) NOT NULL,
  `uv_count` int(11) NOT NULL,
  `static_timestamp` varchar(20)  NOT NULL,
  `static_date` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
