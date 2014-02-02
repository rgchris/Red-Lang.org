##
## NEW DATABASE
##

DROP DATABASE IF EXISTS `db_red`;
CREATE DATABASE IF NOT EXISTS `db_red` CHARACTER SET utf8 COLLATE utf8_general_ci;
USE `db_red`;

DROP TABLE IF EXISTS `sessions`;
CREATE TABLE `sessions` (
	`id` VARBINARY(23) NOT NULL,
	`created` DATETIME NOT NULL,
	`modified` DATETIME NOT NULL,
	`address` VARBINARY(20),
	`user` VARCHAR(20),
	`message` VARCHAR(600),
	`crumbs` VARBINARY(255),
	`other` VARBINARY(255),
	PRIMARY KEY (`id`),
	INDEX (`modified`)
);

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
	`id` VARCHAR(20) NOT NULL,
	`owner` TINYINT(1),
	`valikey` VARBINARY(23) NOT NULL,
	`toc` TINYINT(1),
	`name` VARCHAR(80) NOT NULL,
	`email` VARBINARY(80) NOT NULL,
	`password` VARCHAR(100) NOT NULL,
	`joined` DATETIME NOT NULL,
	`roles` VARBINARY(255),
	`last_activity` DATETIME NOT NULL,
	`biography` VARCHAR(255),
	`home_page` VARBINARY(150),
	`google_profile` VARBINARY(80),
	`twitter_id` VARCHAR(15),
	`facebook_profile` VARBINARY(80),
	`misc` VARBINARY(255),
	PRIMARY KEY (`id`),
	INDEX (`id`)
);

DROP TABLE IF EXISTS `documents`;
CREATE TABLE `documents` (
	`id` INT(11) NOT NULL auto_increment,
	`name` VARCHAR(60) NOT NULL,
	`title` VARCHAR(60) NOT NULL,
	`kind` ENUM('Item', 'Article', 'News', 'Opinion', 'Concept', 'Resource', 'Author', 'Place', 'Topic', 'Note', 'Wiki', 'Comment') NOT NULL,
	`status` ENUM('Live', 'Archive') NOT NULL,
	`editor` VARCHAR(20) NOT NULL,
	`modified` DATETIME NOT NULL,
	`options` VARBINARY(100),
	`text` TEXT,
	`document` BLOB,
	`html` TEXT,
	`terms` TEXT,
	PRIMARY KEY (`id`),
	INDEX (`name`, `title`, `kind`, `editor`)
);

DROP TABLE IF EXISTS `issues`;
CREATE TABLE `issues` (
	`id` INT(11) NOT NULL auto_increment,
	`summary` VARCHAR(120) NOT NULL,
	`description` TEXT NOT NULL,
	`response` TEXT,
	`severity` ENUM('Feature', 'Trivial', 'Text', 'Tweak', 'Minor', 'Major', 'Crash', 'Block') NOT NULL,
	`status` ENUM('New', 'Feedback', 'Acknowledged', 'Confirmed', 'Assigned', 'Resolved', 'Closed') NOT NULL,
	`resolution` ENUM('Open', 'Fixed', 'Reopened', 'Unconfirmed', 'Unfixable', 'Duplicate', 'No Change', 'Suspended', 'Won\'t Fix') NOT NULL,
	`priority` ENUM('Low', 'Normal', 'Urgent', 'Immediate'),
	`submitted` DATETIME NOT NULL,
	`submitter` VARCHAR(20) NOT NULL,
	`reviewed` DATETIME,
	`reviewer` VARCHAR(20),
	`assignee` VARCHAR(20),
	`resolved` DATETIME,
	PRIMARY KEY (`id`)
);

DROP TABLE IF EXISTS `notes`;
CREATE TABLE `notes` (
	`id` VARCHAR(60) NOT NULL,
	`title` VARCHAR(60) NOT NULL,
	`public` TINYINT(1),
	`document` INT(11) NOT NULL,
	`modified` DATETIME,
	`author` VARCHAR(20) NOT NULL,
	`created` DATETIME NOT NULL,
	PRIMARY KEY (`id`),
	INDEX (`id`)
);

DROP TABLE IF EXISTS `wiki`;
CREATE TABLE `wiki` (
	`id` VARCHAR(60) NOT NULL,
	`title` VARCHAR(60) NOT NULL,
	`public` TINYINT(1),
	`document` INT(11) NOT NULL,
	`modified` DATETIME,
	`author` VARCHAR(20) NOT NULL,
	`created` DATETIME NOT NULL,
	`blogger_id` VARCHAR(60),
	PRIMARY KEY (`id`),
	INDEX (`id`)
);

DROP TABLE IF EXISTS `news`;
CREATE TABLE `news` (
	`id` VARCHAR(80) NOT NULL,
	`title` VARCHAR(60) NOT NULL,
	`name` VARCHAR(60) NOT NULL,
	`status` ENUM('Draft', 'Ready', 'Live') NOT NULL,
	`short` VARCHAR(240) NOT NULL,
	`document` INT(11) NOT NULL,
	`author` VARCHAR(20) NOT NULL,
	`created` DATETIME NOT NULL,
	`published` DATETIME,
	`modified` DATETIME NOT NULL,
	`tags` VARBINARY(400),
	`blogger_id` VARCHAR(80),
	PRIMARY KEY (`id`),
	INDEX (`id`, `title`, `status`, `author`)
);

DROP TABLE IF EXISTS `slideshows`;
CREATE TABLE `slideshows` (
	`id` VARCHAR(16) NOT NULL,
	`title` VARCHAR(60) NOT NULL,
	`type` ENUM('S5', 'Impress') NOT NULL,
	`text` TEXT NOT NULL,
	`html` TEXT NOT NULL,
	`modified` DATETIME,
	`author` VARCHAR(20) NOT NULL,
	`created` DATETIME NOT NULL,
	PRIMARY KEY (`id`),
	INDEX (`id`)
);

DROP TABLE IF EXISTS `tags`;
CREATE TABLE `tags` (
	`id` VARCHAR(24) NOT NULL,
	`description` VARCHAR(240) NOT NULL
);

DROP TABLE IF EXISTS `authors_news`;
CREATE TABLE `authors_news` (
	`author` VARCHAR(20) NOT NULL,
	`item` VARCHAR(80) NOT NULL
);

DROP TABLE IF EXISTS `authors_wiki`;
CREATE TABLE `authors_wiki` (
	`author` VARCHAR(20) NOT NULL,
	`page` VARCHAR(60) NOT NULL
);

DROP TABLE IF EXISTS `tags_news`;
CREATE TABLE `tags_news` (
	`tag` VARCHAR(24) NOT NULL,
	`item` VARCHAR(80) NOT NULL
);

DROP TABLE IF EXISTS `tags_wiki`;
CREATE TABLE `tags_wiki` (
	`tag` VARCHAR(24) NOT NULL,
	`page` VARCHAR(60) NOT NULL
);

