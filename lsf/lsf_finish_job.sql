
DROP TABLE IF EXISTS `finish_job`;

CREATE TABLE `finish_job` (
`internal_id` INT NOT NULL AUTO_INCREMENT,
`job_id` INTEGER DEFAULT NULL,
`user_id` INTEGER DEFAULT NULL,
`user_name` text(255) DEFAULT NULL,
`options` INTEGER DEFAULT NULL,
`num_processors` INTEGER DEFAULT NULL,
`j_status` INTEGER DEFAULT NULL,
`submit_time` bigint  DEFAULT NULL,
`start_time` bigint DEFAULT NULL,
`end_time` bigint DEFAULT NULL,
`queue` text(255) DEFAULT NULL,
`resource_req` text(255) DEFAULT NULL,
`from_host` text(255) DEFAULT NULL,
`cwd` text(255) DEFAULT NULL,
`in_file` text(255) DEFAULT NULL,
`out_file` text(255) DEFAULT NULL,
`err_file` text(255) DEFAULT NULL,
`in_file_spool` text(255) DEFAULT NULL,
`command_Spool` text(255) DEFAULT NULL,
`job_file` text(255) DEFAULT NULL,
`num_asked_hosts` INTEGER DEFAULT NULL,
`asked_hosts` text(255) DEFAULT NULL,
`host_factor` DOUBLE DEFAULT NULL,
`num_ex_hosts` INTEGER DEFAULT NULL,
`exec_hosts` text(255) DEFAULT NULL,
`cpu_time` DOUBLE DEFAULT NULL,
`job_name` text(255) DEFAULT NULL,
`depend_cond` text(255) DEFAULT NULL,
`time_event` text(255) DEFAULT NULL,
`pre_exec_cmd` text(255) DEFAULT NULL,
`mail_user` text(255) DEFAULT NULL,
`project_name` text(255) DEFAULT NULL,
`exit_status` INTEGER DEFAULT NULL,
`max_num_processors` INTEGER DEFAULT NULL,
`login_shell` text(255) DEFAULT NULL,
`idx` INTEGER DEFAULT NULL,
`max_rmem` INTEGER DEFAULT NULL,
`max_rswap` INTEGER DEFAULT NULL,
`rsv_id` text(255) DEFAULT NULL,
`sla` text(255) DEFAULT NULL,
`except_mask` INTEGER DEFAULT NULL,
`additional_Info` text(255) DEFAULT NULL,
`exit_info` INTEGER DEFAULT NULL,
`warning_time_period` INTEGER DEFAULT NULL,
`warning_action` text(255) DEFAULT NULL,
`charged_SAAP` text(255) DEFAULT NULL,
`license_project` text(255) DEFAULT NULL,
`app` text(255) DEFAULT NULL,
`post_exec_cmd` text(255) DEFAULT NULL,
`runtime_estimation` INTEGER DEFAULT NULL,
`jgroup` text(255) DEFAULT NULL,
`options2` INTEGER DEFAULT NULL,
`requeue_e_values` text(255) DEFAULT NULL,
`notify_cmd` text(255) DEFAULT NULL,
`last_resize_time` bigint  DEFAULT NULL,
`job_description` text(255) DEFAULT NULL,
`command` mediumtext default null,
 primary key (internal_id,submit_time),
 key(job_id),
 key(user_id),
 key(user_name(255)),
 key(submit_time),
 key(start_time),
 key(end_time),
 key(queue(255)),
 key(cwd(255))

) ENGINE=MyISAM DEFAULT CHARSET=latin1
PARTITION BY RANGE (submit_time) (
   partition p0 values less than (1328072400),
   partition p1 values less than (1330578000),
   partition p2 values less than (1333252800),
   partition p3 values less than (1335844800),
   partition p4 values less than (1338523200),
   partition p5 values less than maxvalue
 
);
unlock tables;