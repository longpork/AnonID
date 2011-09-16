-- -----------------------------------------------------
-- procedure enable
-- 
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
	DECLARE uid BIGINT UNSIGNED;
	DECLARE ptype ENUM('LOGIN', 'ADMIN', 'DURESS');
	DECLARE status enum('ACTIVE','LOCKED','DISABLED');

	IF (authCookieIsValid(ac)) THEN
		SELECT u.id,u.status,s.type INTO uid,status,ptype 
			FROM shadow s
			RIGHT JOIN ( SELECT * FROM authCookies WHERE id = ac )
			auth ON auth.userid = s.id
			WHERE password=PASSWORD(CONCAT(s.salt, passwd));
		IF (FOUND_ROWS() = 0) THEN
			SELECT false STATUS, "Invalid Credential!";
		ELSE
			-- XXX make a new auth cookie and return it!
		END IF;		
	ELSE
		select false STATUS, "Invalid Cookie" MESSAGE;
	END IF;
END $$

$$
DELIMITER ;