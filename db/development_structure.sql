CREATE TABLE `comments` (
  `id` int(11) NOT NULL auto_increment,
  `comment` text collate utf8_bin NOT NULL,
  `commentable_id` int(10) NOT NULL,
  `commentable_type` varchar(50) collate utf8_bin NOT NULL,
  `ip_address` varchar(255) collate utf8_bin NOT NULL,
  `name` varchar(80) collate utf8_bin NOT NULL,
  `email` varchar(255) collate utf8_bin NOT NULL,
  `website` varchar(255) collate utf8_bin NOT NULL default '',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE `generated_pieces` (
  `id` int(11) NOT NULL auto_increment,
  `user_ip_address` varchar(255) collate utf8_bin NOT NULL,
  `fractal_piece` mediumtext collate utf8_bin,
  `generated_midi_file` varchar(255) collate utf8_bin NOT NULL,
  `generated_guido_file` varchar(255) collate utf8_bin NOT NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `germ` varchar(255) collate utf8_bin NOT NULL default '',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=487 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE `ip_addresses` (
  `id` int(11) NOT NULL auto_increment,
  `ip_address` varchar(20) collate utf8_bin NOT NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_ip_addresses_on_ip_address` (`ip_address`)
) ENGINE=InnoDB AUTO_INCREMENT=68 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE `page_html_parts` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) collate utf8_bin NOT NULL,
  `content` mediumtext collate utf8_bin,
  `content_html` mediumtext collate utf8_bin,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE `ratings` (
  `id` int(11) NOT NULL auto_increment,
  `rater_id` int(10) default NULL,
  `rated_id` int(10) default NULL,
  `rated_type` varchar(255) collate utf8_bin default NULL,
  `rating` decimal(10,0) default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_ratings_on_rater_id` (`rater_id`),
  KEY `index_ratings_on_rated_type_and_rated_id` (`rated_type`,`rated_id`)
) ENGINE=InnoDB AUTO_INCREMENT=115 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE `schema_info` (
  `version` int(10) default NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `sessions` (
  `id` int(11) NOT NULL auto_increment,
  `session_id` varchar(255) collate utf8_bin NOT NULL,
  `data` mediumtext collate utf8_bin,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_sessions_on_session_id` (`session_id`),
  KEY `index_sessions_on_updated_at` (`updated_at`)
) ENGINE=InnoDB AUTO_INCREMENT=4244 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE `user_submission_unique_page_views` (
  `id` int(11) NOT NULL auto_increment,
  `user_submission_id` int(10) NOT NULL,
  `ip_address` varchar(20) collate utf8_bin NOT NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `fk_user_submission_unique_page_views` (`user_submission_id`),
  CONSTRAINT `fk_user_submission_unique_page_views` FOREIGN KEY (`user_submission_id`) REFERENCES `user_submissions` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=392 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE `user_submissions` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) collate utf8_bin NOT NULL,
  `email` varchar(255) collate utf8_bin NOT NULL,
  `display_email` tinyint(1) NOT NULL default '0',
  `comment_notification` tinyint(1) NOT NULL default '1',
  `website` varchar(255) collate utf8_bin default NULL,
  `title` varchar(255) collate utf8_bin NOT NULL,
  `description` varchar(255) collate utf8_bin default NULL,
  `generated_piece_id` int(10) NOT NULL,
  `processing_began` datetime default NULL,
  `processing_completed` datetime default NULL,
  `piece_mp3_file` varchar(255) collate utf8_bin default NULL,
  `piece_pdf_file` varchar(255) collate utf8_bin default NULL,
  `piece_image_file` varchar(255) collate utf8_bin default NULL,
  `germ_mp3_file` varchar(255) collate utf8_bin default NULL,
  `germ_image_file` varchar(255) collate utf8_bin default NULL,
  `comment_count` int(10) NOT NULL default '0',
  `total_page_views` int(10) NOT NULL default '0',
  `unique_page_views` int(10) NOT NULL default '0',
  `rating_count` int(10) default NULL,
  `rating_total` decimal(10,0) default NULL,
  `rating_avg` decimal(10,2) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `slug` varchar(1024) collate utf8_bin NOT NULL default '',
  PRIMARY KEY  (`id`),
  KEY `fk_user_submissions_generated_piece_id_to_generated_pieces` (`generated_piece_id`),
  CONSTRAINT `fk_user_submissions_generated_piece_id_to_generated_pieces` FOREIGN KEY (`generated_piece_id`) REFERENCES `generated_pieces` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

INSERT INTO `schema_info` (version) VALUES (8)