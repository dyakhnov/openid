DROP DATABASE IF EXISTS `openid`;
CREATE DATABASE IF NOT EXISTS `openid`;
USE `openid`;

DROP TABLE IF EXISTS `openid_trusted`;
CREATE TABLE `openid_trusted` (
  `TrustedID` varchar(35) NOT NULL default '',
  `TrustedRoot` varchar(255) NOT NULL default '',
  PRIMARY KEY  (`TrustedID`),
  UNIQUE KEY `TrustedID` (`TrustedID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `openid_sessions`;
CREATE TABLE `openid_sessions` (
  `dtCreated` datetime NOT NULL default '0000-00-00 00:00:00',
  `Handle` varchar(32) NOT NULL default '',
  `Secret` varchar(20) NOT NULL default '',
  PRIMARY KEY  (`Handle`),
  UNIQUE KEY `Handle` (`Handle`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `UserID` varchar(35) NOT NULL default '',
  `Username` varchar(32) NOT NULL default '',
  `Userpass` varchar(32) NOT NULL default '',
  `Email` varchar(128) NOT NULL default '',
  `Fullname` varchar(255) NOT NULL default '',
  PRIMARY KEY  (`UserID`),
  UNIQUE KEY `UserID` (`UserID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `users` VALUES ('06DD448D-FE74-B0EC-90A6D7D9C2FB0651','test','098F6BCD4621D373CADE4E832627B4F6','test@test.com','Test');

