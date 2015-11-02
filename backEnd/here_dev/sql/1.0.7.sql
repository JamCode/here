DROP TABLE IF EXISTS  `static_pv_uv`;
CREATE TABLE `static_pv_uv` (
  `static_id` varchar(100) NOT NULL,
  `pv_count` int(11) NOT NULL,
  `uv_count` int(11) NOT NULL,
  `static_timestamp` timestamp  NOT NULL DEFAULT current_timestamp ,
  `static_date` timestamp NOT NULL,
  PRIMARY KEY (`static_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
