SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

DROP SCHEMA IF EXISTS `AnonID` ;
CREATE SCHEMA IF NOT EXISTS `AnonID` DEFAULT CHARACTER SET latin1 ;
USE `AnonID` ;

-- -----------------------------------------------------
-- Table `users`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `users` ;

CREATE  TABLE IF NOT EXISTS `users` (
  `id` BIGINT(20) UNSIGNED NOT NULL ,
  `name` VARCHAR(96) NOT NULL ,
  `status` ENUM('ACTIVE','LOCKED', 'DISABLED') NOT NULL ,
  PRIMARY KEY (`id`) ,
  UNIQUE INDEX `id_UNIQUE` (`id` ASC) ,
  UNIQUE INDEX `name_UNIQUE` (`name` ASC) )
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `FormRegistry`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `FormRegistry` ;

CREATE  TABLE IF NOT EXISTS `FormRegistry` (
  `id` BIGINT(20) UNSIGNED NOT NULL ,
  `userid` BIGINT(20) UNSIGNED NOT NULL ,
  `created` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `expires` TIMESTAMP NOT NULL DEFAULT '1970-01-01 00:00:01' ,
  `class` TEXT NOT NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `fk_FormRegistry_1` (`id` ASC) ,
  CONSTRAINT `fk_FormRegistry_1`
    FOREIGN KEY (`id` )
    REFERENCES `users` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `realms`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `realms` ;

CREATE  TABLE IF NOT EXISTS `realms` (
  `id` BIGINT(20) UNSIGNED NOT NULL ,
  `userid` BIGINT(20) UNSIGNED NOT NULL ,
  `url` TEXT NOT NULL ,
  `updated` DATETIME NOT NULL ,
  `EXPIRES` DATETIME NULL DEFAULT NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `fk_siteApproval_1` (`userid` ASC) ,
  INDEX `fk_realms_1` (`userid` ASC) ,
  CONSTRAINT `fk_realms_1`
    FOREIGN KEY (`userid` )
    REFERENCES `users` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `userAttributes`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `userAttributes` ;

CREATE  TABLE IF NOT EXISTS `userAttributes` (
  `id` BIGINT(20) UNSIGNED NOT NULL ,
  `userid` BIGINT(20) UNSIGNED NOT NULL ,
  `name` TEXT NOT NULL ,
  `origin` BIGINT(20) UNSIGNED NOT NULL ,
  `type` TEXT NOT NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `fk_peronaAttributes_1` (`userid` ASC) ,
  INDEX `fk_relm_origin` (`origin` ASC) ,
  INDEX `fk_userAttributes_1` (`origin` ASC) ,
  CONSTRAINT `fk_peronaAttributes_1`
    FOREIGN KEY (`userid` )
    REFERENCES `users` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_userAttributes_1`
    FOREIGN KEY (`origin` )
    REFERENCES `realms` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `acl`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `acl` ;

CREATE  TABLE IF NOT EXISTS `acl` (
  `attributeid` BIGINT(20) UNSIGNED NOT NULL ,
  `realmid` BIGINT(20) UNSIGNED NOT NULL ,
  `read` TINYINT(1) NULL DEFAULT NULL ,
  `set` TINYINT(1) NULL DEFAULT NULL ,
  INDEX `fk_acl_1` (`attributeid` ASC) ,
  INDEX `fk_acl_2` (`realmid` ASC) ,
  CONSTRAINT `fk_acl_1`
    FOREIGN KEY (`attributeid` )
    REFERENCES `userAttributes` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_acl_2`
    FOREIGN KEY (`realmid` )
    REFERENCES `realms` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `attribValues`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `attribValues` ;

CREATE  TABLE IF NOT EXISTS `attribValues` (
  `attributeid` BIGINT(20) UNSIGNED NOT NULL ,
  `index` INT(10) UNSIGNED NULL DEFAULT NULL ,
  `value` TEXT NOT NULL ,
  INDEX `fk_attribValues_1` (`attributeid` ASC) ,
  CONSTRAINT `fk_attribValues_1`
    FOREIGN KEY (`attributeid` )
    REFERENCES `userAttributes` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `authCookies`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `authCookies` ;

CREATE  TABLE IF NOT EXISTS `authCookies` (
  `id` BIGINT(19) UNSIGNED NOT NULL ,
  `type` ENUM('LOGIN', 'ADMIN', 'DURESS') NOT NULL ,
  `userid` BIGINT(20) UNSIGNED NOT NULL ,
  `created` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  `lifetime` INT NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`) ,
  INDEX `fk_authCookies_1` (`userid` ASC) ,
  CONSTRAINT `fk_authCookies_1`
    FOREIGN KEY (`userid` )
    REFERENCES `users` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `shadow`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `shadow` ;

CREATE  TABLE IF NOT EXISTS `shadow` (
  `uid` BIGINT(20) UNSIGNED NOT NULL ,
  `salt` CHAR(8) NOT NULL,
  `password` CHAR(41) NOT NULL ,
  `type` ENUM('LOGIN', 'ADMIN', 'DURESS') NOT NULL ,
  INDEX `fk_shadow_1` (`uid` ASC) ,
  CONSTRAINT `fk_shadow_1`
    FOREIGN KEY (`uid` )
    REFERENCES `users` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;
