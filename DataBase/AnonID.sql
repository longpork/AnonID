-- -----------------------------------------------------
-- procedure addUserAttribute
-- -----------------------------------------------------

USE `AnonID`;
DROP procedure IF EXISTS `addUserAttribute`;
DELIMITER $$
USE `AnonID`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `addUserAttribute`(
IN in_user TEXT,
IN in_name TEXT,
IN in_type TEXT,
IN in_relm TEXT
)
BEGIN
declare pid BIGINT;
declare originid BIGINT;
select id into pid from users where name = in_user;
select id into originid from relms where name = in_relm;
INSERT into userAttributes (userid, name, type, origin) values (pid, in_name, in_type, originid);
END$$

$$
DELIMITER ;


-- -----------------------------------------------------
-- procedure approveRealm
-- -----------------------------------------------------

USE `AnonID`;
DROP procedure IF EXISTS `approveRealm`;
DELIMITER $$
USE `AnonID`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `approveRealm`(
	IN in_user VARCHAR(96), 
	IN in_url TEXT, 
	IN in_expires DATETIME
)
BEGIN
	DECLARE randID BIGINT unsigned;
	DECLARE rid INT;
	DECLARE idexists INT;
	DECLARE pid BIGINT;
	DECLARE updated INT;

	# Check for realm
	SELECT count(u.id) into idexists 
		FROM realms r inner join user u
			ON r.userid = u.id
		WHERE r.url = in_url AND u.name = in_user;
		
	IF idexists < 1 THEN
		# Add it
		SELECT id into pid from users WHERE name = in_user;
		SET idexists = 1;
		WHILE idexists > 0 DO
			SELECT (FLOOR(1 + (RAND() * 2147483646))) into randID;
			SELECT count(id) FROM realms WHERE id = randID into idexists;
		END WHILE;
		INSERT INTO realms (id, userid, url, updated, EXPIRES)
			VALUES (randID, pid, in_url,NOW(), in_expires);
	ELSE
		#update it
		UPDATE  realms r inner join user u
			ON r.userid = u.id
			SET r.expires = in_expires
			WHERE r.url = in_url AND u.name = in_user;		
	END IF;
END$$

$$
DELIMITER ;


-- -----------------------------------------------------
-- function authIsExpired
-- -----------------------------------------------------

USE `AnonID`;
DROP function IF EXISTS `authIsExpired`;
DELIMITER $$
USE `AnonID`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `authIsExpired`(
in_date DATETIME,
in_interval TIME 
) RETURNS tinyint(1)
BEGIN
	DECLARE good INT;
	select  (ADDDATE(in_date, INTERVAL TIME_TO_SEC(in_interval) SECOND ) > NOW()) into good;
	return good;
END$$

$$
DELIMITER ;


-- -----------------------------------------------------
-- function checkRelmStatus
-- -----------------------------------------------------

USE `AnonID`;
DROP function IF EXISTS `checkRelmStatus`;
DELIMITER $$
USE `AnonID`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `checkRelmStatus`(
in_authTok BIGINT,
in_realm TEXT
) RETURNS tinyint(1)
BEGIN
DECLARE res int;
select count(r.id) into res 
	FROM authCookies a LEFT JOIN realms r
		ON a.userid = r.userid
	WHERE a.id = in_authTok
	AND    r.url = in_realm
	AND (r.EXPIRES > NOW() OR r.EXPIRES is NULL)
	AND NOT authIsExpired(a.created, a.lifetime);
return res;
END$$

$$
DELIMITER ;


-- -----------------------------------------------------
-- procedure dblogin
-- -----------------------------------------------------

USE `AnonID`;
DROP procedure IF EXISTS `dblogin`;
DELIMITER $$
USE `AnonID`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `dblogin`(
IN in_name VARCHAR(96),
IN in_passwd VARCHAR(255)
)
BEGIN
	DECLARE token BIGINT UNSIGNED;
	DECLARE uid BIGINT UNSIGNED;
	DECLARE type enum('NORMAL', 'DURESS', 'ADMIN');
	DECLARE status enum('ACTIVE','LOCKED','INACTIVE');
	DECLARE found int;

	SELECT u.id,u.status,s.type INTO uid,status,type 
		FROM users u INNER JOIN shadow s 
		ON u.id = s.uid
		WHERE u.name=in_name
		AND password=PASSWORD(CONCAT(in_name, in_passwd));

	IF (status = 'ACTIVE') THEN
		set found = 1;
		WHILE found > 0 DO
			select (FLOOR(1 + (RAND() * 2147483646))) into token;
			select count(id) from authCookies where id = token into found;
		END WHILE;
		INSERT INTO authCookies (id, userid, type, lifetime)
			VALUES (token, uid, type, NOW());
		SELECT token,type;
	ELSE
		select status,type;
	END IF;

END$$

$$
DELIMITER ;


-- -----------------------------------------------------
-- procedure getUserAttribute
-- -----------------------------------------------------

USE `AnonID`;
DROP procedure IF EXISTS `getUserAttribute`;
DELIMITER $$
USE `AnonID`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `getUserAttribute`(
IN in_token BIGINT UNSIGNED,
IN in_name TEXT
)
BEGIN
DECLARE authOk boolean;
DECLARE pid BIGINT UNSIGNED;
SET authOk = false;
# check auth

SELECT userid INTO pid
	FROM authCookies 
	WHERE id = in_token AND NOT authIsExpired(created, lifetime);

IF pid is not null then
	SELECT av.index,av.value  
		FROM attribValues  av
		LEFT JOIN userAttributes pa 
			on av.attributeid = pa.id
		WHERE pa.userid = pid
			AND pa.name = in_name
		ORDER BY av.index;
	ELSE
		SELECT "Invalid Auth Cookie" as error;
		# TODO - log this!
	END IF;
END$$

$$
DELIMITER ;


-- -----------------------------------------------------
-- procedure getRealmAttrAuth
-- -----------------------------------------------------

USE `AnonID`;
DROP procedure IF EXISTS `getRealmAttrAuth`;
DELIMITER $$
USE `AnonID`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `getRealmAttrAuth`(
IN in_token	BIGINT UNSIGNED,
IN in_realm TEXT
)
BEGIN
DECLARE pid BIGINT UNSIGNED;

SELECT userid INTO pid
	FROM authCookies 
	WHERE id = in_token AND NOT authIsExpired(created, lifetime);

SELECT pa.name,acl.read,acl.set 
	FROM acl left join userAttributes pa
		ON pa.id = acl.attributeid
	LEFT JOIN realms r 
		ON r.id = acl.realmid
	WHERE r.url = in_realm;
END$$

$$
DELIMITER ;


-- -----------------------------------------------------
-- procedure getRealmInfo
-- -----------------------------------------------------

USE `AnonID`;
DROP procedure IF EXISTS `getRealmInfo`;
DELIMITER $$
USE `AnonID`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `getRealmInfo`(
IN in_tok BIGINT UNSIGNED,
IN in_realm TEXT
)
BEGIN
	SELECT  
		r.url,
		r.expires,
		r.updated
	FROM authCookies a 
		CROSS JOIN realms r
			ON a.userid = r.userid
	WHERE  a.id   = in_tok
		AND    r.url = in_realm;
END$$

$$
DELIMITER ;


-- -----------------------------------------------------
-- function hasUser
-- -----------------------------------------------------

USE `AnonID`;
DROP function IF EXISTS `hasUser`;
DELIMITER $$
USE `AnonID`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `hasUser`(
user VARCHAR(96)
) RETURNS tinyint(1)
BEGIN
	DECLARE count INT;
	SELECT count(name) AS count FROM users
		WHERE users.userName = user
		AND users.status = 'ACTIVE' 
		AND users.name = user 
		INTO count; 
	CASE
		WHEN count = 1 THEN return 1;
	ELSE
		return 0;
	END CASE;
END$$

$$
DELIMITER ;


-- -----------------------------------------------------
-- function userExists
-- -----------------------------------------------------

USE `AnonID`;
DROP function IF EXISTS `userExists`;
DELIMITER $$
USE `AnonID`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `userExists`(
in_user VARCHAR(24)
) RETURNS tinyint(1)
BEGIN
	DECLARE res int;
	select count(name) into res from users 
		WHERE name = in_user 
		AND status = 'ACTIVE';
	return res;
END$$

$$
DELIMITER ;


-- -----------------------------------------------------
-- procedure registerForm
-- -----------------------------------------------------

USE `AnonID`;
DROP procedure IF EXISTS `registerForm`;
DELIMITER $$
USE `AnonID`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `registerForm`(
IN in_token BIGINT unsigned,
IN in_lifetime INT,
IN in_class TEXT
)
BEGIN
DECLARE pid BIGINT unsigned;
DECLARE found int;
DECLARE formID BIGINT UNSIGNED;
DECLARE exp TIMESTAMP;

SELECT userid into pid
	FROM authCookies
	WHERE id = in_token AND NOT (authIsExpired(created, lifetime));

IF pid is not null then
	set found = 1;
	WHILE found > 0 DO
		select (FLOOR(1 + (RAND() * 2147483646))) into formID;
		select count(id) from authCookies where id = formID into found;
	END WHILE;
	
	SET exp = (in_lifetime * 1000) + CURRENT_TIMESTAMP();
	insert into FormRegistry (id, userid, submitted, created, expires, class) 
		values (formID, pid, FALSE, CURRENT_TIMESTAMP(), exp, in_class);
	select formID as "token", exp as "expires";
ELSE
	select "Invalid Auth Cookie" as error;
END IF;
END$$

$$
DELIMITER ;


-- -----------------------------------------------------
-- function AnonActivateUser
-- -----------------------------------------------------

USE `AnonID`;
DROP function IF EXISTS `AnonActivateUser`;
DELIMITER $$
USE `AnonID`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `AnonActivateUser`(
user VARCHAR(8)
) RETURNS enum('OK','LOCKED') CHARSET latin1
BEGIN
	DECLARE userStatus enum('ACTIVE','LOCKED','INACTIVE');
	SELECT status FROM users WHERE userName = user INTO userStatus;
	IF (userStatus = 'LOCKED') THEN 
		return 'LOCKED';
	ELSE
 		UPDATE users  SET status = 'ACTIVE' WHERE userName = user;
		return 'OK';
	END IF;
END$$

$$
DELIMITER ;


-- -----------------------------------------------------
-- function AnonAddUser
-- -----------------------------------------------------

USE `AnonID`;
DROP function IF EXISTS `AnonAddUser`;
DELIMITER $$
USE `AnonID`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `AnonAddUser`(
user VARCHAR(8),
passwd VARCHAR(255),
duress VARCHAR(255)
) RETURNS enum('OK','EXISTS') CHARSET latin1
BEGIN
	DECLARE randID BIGINT unsigned;
	DECLARE found INT;
	SET found = 1;
	WHILE found > 0 DO
		select (FLOOR(1 + (RAND() * 2147483646))) into randID;
		select count(id) from users where id = randID into found;
	END WHILE;
	
	SELECT COUNT(id) from users WHERE userName = user INTO found;
	IF found > 0 THEN
		return 'EXISTS';	
	ELSE
		INSERT INTO users (id, userName, status)  VALUES (randID, user, 'INACTIVE');
		INSERT INTO shadow (uid, password, type) VALUES (randID, PASSWORD(CONCAT(user,passwd)), 'NORMAL');
		INSERT INTO shadow (uid, password, type) VALUES (randID, PASSWORD(CONCAT(user,duress)), 'DURESS');
		return 'OK';
	END IF;	
END$$

$$
DELIMITER ;


-- -----------------------------------------------------
-- function AnonCheckPasswd
-- -----------------------------------------------------

USE `AnonID`;
DROP function IF EXISTS `AnonCheckPasswd`;
DELIMITER $$
USE `AnonID`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `AnonCheckPasswd`(
user VARCHAR(8),
passwd VARCHAR(255)
) RETURNS enum('OK','DURESS','LOCKED','INACTIVE','NOMATCH') CHARSET latin1
BEGIN
	DECLARE res_type enum('NORMAL','DURESS');
	DECLARE res_status enum('ACTIVE','LOCKED','INACTIVE');
	SELECT type, status 
	FROM users RIGHT JOIN shadow
	ON users.id=shadow.uid
	WHERE userName=user
		AND password=PASSWORD(CONCAT(user, passwd)) 
	INTO res_type,res_status;
	
	CASE
		WHEN res_type = 'DURESS' THEN return 'DURESS';
		WHEN res_status = 'LOCKED' THEN return 'LOCKED';
		WHEN res_status = 'INACTIVE' THEN return 'INACTIVE';
		WHEN res_type = 'NORMAL' THEN  return 'OK';
	ELSE
		return 'NOMATCH';
	END CASE;
	return 'NOMATCH';
END$$

$$
DELIMITER ;



SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
