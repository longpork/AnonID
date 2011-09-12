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
	DECLARE ptype ENUM('LOGIN', 'ADMIN', 'DURESS');
	DECLARE status enum('ACTIVE','LOCKED','DISABLED');
	DECLARE found int;

	SELECT u.id,u.status,s.type INTO uid,status,ptype 
		FROM users u INNER JOIN shadow s 
		ON u.id = s.uid
		WHERE u.name=in_name
		AND password=PASSWORD(CONCAT(s.salt, in_passwd));

	IF (status = 'ACTIVE' AND ptype = 'LOGIN') THEN
		set found = 1;
		WHILE found > 0 DO
			SET token=(FLOOR(1 + (RAND() * 9223372036854775807)));
			select count(id) from authCookies where id = token into found;
		END WHILE;
		INSERT INTO authCookies (id, userid, type, lifetime)
			VALUES (token, uid, ptype, 60);
		SELECT true STATUS,token TOKEN;
	ELSE
		SELECT false STATUS,"Invalid Credentials!" MESSAGE;
	END IF;

END$$

$$
DELIMITER ;
