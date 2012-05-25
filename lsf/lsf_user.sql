drop table if exists `user`;

create table `user` (
   `user_internal_id` int unique not null auto_increment,
   `user_name` text(255) default null,
   `group_name`     text(255) default null,
   primary key (user_internal_id),
   key (user_name(255)),
   key(group_name(255))
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

