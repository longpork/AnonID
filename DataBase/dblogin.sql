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
	DECLARE type enum('NORMAL', 'ADMIN', 'DURESS');
	DECLARE status enum('ACTIVE','LOCKED','DISABLED');
	DECLARE found int;

	SELECT u.id,u.status,s.type INTO uid,status,type 
		FROM users u INNER JOIN shadow s 
		ON u.id = s.uid
		WHERE u.name=in_name
		AND password=PASSWORD(CONCAT(s.salt, in_passwd));

	IF (status = 'ACTIVE') THEN
		set found = 1;
		WHILE found > 0 DO
			select (FLOOR(1 + (RAND() * 2147483646))) into token;
			select count(id) from authCookies where id = token into found;
		END WHILE;
		INSERT INTO authCookies (id, userid, type, lifetime)
			VALUES (token, uid, type, 3600);
		SELECT true success,token,type;
	ELSE
		SELECT false success,type message;
	END IF;

END$$

$$
DELIMITER ;