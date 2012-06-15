drop table if exists `user`;

create table `user` (
   `user_internal_id` int unique not null auto_increment,
   `user_name` text(255) default null,
   primary key (user_internal_id),
   key (user_name(255))
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

drop table if exists `user_group`;

create table `user_group` (
   `user_internal_id` int not null,
   `group_internal_id` int not null,

   primary key (user_internal_id,group_internal_id)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

drop table if exists `group`;

create table `group` (
   `group_internal_id` int unique not null auto_increment,
   `group_name` text(255) default null,
   primary key (group_internal_id),
   key (group_name(255))
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
