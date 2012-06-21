
DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user` (
  `user_internal_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_name` tinytext,
  PRIMARY KEY (`user_internal_id`),
  UNIQUE KEY `user_internal_id` (`user_internal_id`),
  KEY `user_name` (`user_name`(255))
) ENGINE=MyISAM AUTO_INCREMENT=10268 DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS `user_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_group` (
  `user_internal_id` int(11) NOT NULL,
  `labgroup_internal_id` int(11) NOT NULL,
  PRIMARY KEY (`user_internal_id`,`labgroup_internal_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS `group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `labgroup` (
  `labgroup_internal_id` int(11) NOT NULL AUTO_INCREMENT,
  `labgroup_name` tinytext,
  PRIMARY KEY (`labgroup_internal_id`),
  UNIQUE KEY `labgroup_internal_id` (`labgroup_internal_id`),
  KEY `labgroup_name` (`labgroup_name`(255))
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
