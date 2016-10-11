CREATE TABLE `authors` (
  `id` int(11) NOT NULL auto_increment,
  `first_name` varchar(255) default NULL,
  `last_name` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `authors_books` (
  `author_id` int(11) NOT NULL,
  `book_id` int(11) NOT NULL,
  KEY `fk_bk_authors` (`author_id`),
  KEY `fk_bk_books` (`book_id`),
  CONSTRAINT `fk_bk_books` FOREIGN KEY (`book_id`) REFERENCES `books` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_bk_authors` FOREIGN KEY (`author_id`) REFERENCES `authors` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `books` (
  `id` int(11) NOT NULL auto_increment,
  `title` varchar(255) NOT NULL,
  `publisher_id` int(11) NOT NULL,
  `published_at` datetime default NULL,
  `isbn` varchar(13) default NULL,
  `blurb` text,
  `page_count` int(11) default NULL,
  `price` float default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `cover_image` varchar(255) default NULL,
  PRIMARY KEY  (`id`),
  KEY `fk_books_publishers` (`publisher_id`),
  CONSTRAINT `fk_books_publishers` FOREIGN KEY (`publisher_id`) REFERENCES `publishers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `cart_items` (
  `id` int(11) NOT NULL auto_increment,
  `book_id` int(11) default NULL,
  `cart_id` int(11) default NULL,
  `price` float default NULL,
  `amount` int(11) default NULL,
  `created_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `carts` (
  `id` int(11) NOT NULL auto_increment,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `forum_posts` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(50) NOT NULL,
  `subject` varchar(255) NOT NULL,
  `body` text,
  `root_id` int(11) NOT NULL default '0',
  `parent_id` int(11) NOT NULL default '0',
  `lft` int(11) NOT NULL default '0',
  `rgt` int(11) NOT NULL default '0',
  `depth` int(11) NOT NULL default '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `publishers` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `schema_info` (
  `version` int(11) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

INSERT INTO schema_info (version) VALUES (7)