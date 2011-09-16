-- -----------------------------------------------------
-- procedure enable
-- dblogin for elevated access. This just enables admin
-- commands, it does not grant access to anything.
-- -----------------------------------------------------

USE `AnonID`;
DROP procedure IF EXISTS `enable`;
DELIMITER $$
USE `AnonID`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `enable`(
IN ac BIGINT(20),
IN passwd VARCHAR(255)
)
BEGIN
	DECLARE token BIGINT UNSIGNED;
	DECLARE uid BIGINT UNSIGNED;
	DECLARE ptype ENUM('LOGIN', 'ADMIN', 'DURESS');
	DECLARE status enum('ACTIVE','LOCKED','DISABLED');
	DECLARE found int;
	
	IF (authCookieIsValid(ac)) THEN
		SELECT u.id,u.status,s.type INTO uid,status,ptype 
			FROM shadow s
			JOIN ( SELECT * FROM authCookies WHERE id = ac )
			auth ON auth.userid = s.id
			WHERE password=PASSWORD(CONCAT(s.salt, passwd));
		IF (FOUND_ROWS() = 0) THEN
			-- XXX: Log!
			SELECT false STATUS, "Invalid Credential!" MESSAGE;
		ELSEIF (ptype = 'ADMIN') THEN
			SET found = 1;
			WHILE found > 0 DO
					SET token=(FLOOR(1 + (RAND() * 9223372036854775807)));
					select count(id) from authCookies where id = token into found;
			END WHILE;
			INSERT INTO authCookies (id, userid, type, lifetime)
			VALUES (token, uid, ptype, 30);
		ELSEIF (ptype = 'DURESS') THEN
			-- XXX: LOG!
			SELECT false STATUS, "Invalid Credential!" MESSAGE;
		ELSEIF (ptype = 'DURESS') THEN
			-- XXX: LOG!
			SELECT false STATUS, "Invalid Credential!" MESSAGE;
		END IF;	
	ELSE 
		SELECT false STATUS, "Invalid Cookie!" MESSAGE;
	END IF;
END $$

$$
DELIMITER ;