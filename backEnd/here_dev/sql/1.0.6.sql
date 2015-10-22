#84
ALTER TABLE `private_message_info` add column `datetime` varchar(50) after `send_timestamp`;

#87
ALTER TABLE `content_base_info` change `content_publish_date` varchar(50);

#94
ALTER TABLE `confirm_phone` drop primary key;