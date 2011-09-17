-- -----------------------------------------------------
-- procedure adminCreateUser
-- -----------------------------------------------------

USE `AnonID`;
DROP procedure IF EXISTS `adminCreateUser`;
DELIMITER $$
USE `AnonID`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `adminCreateUser`(
IN lc BIGINT(20),
IN ec BIGINT(20),
IN newname VARCHAR(96),
IN newpasswd VARCHAR(255)
)
BEGIN
	DECLARE token BIGINT UNSIGNED;
	DECLARE userexists BOOLEAN;
	DECLARE found int;
	DECLARE salt CHAR(8);
	
	SELECT COUNT(*) INTO userexists FROM users u WHERE u.name = newname;
	IF (userexists) THEN
		SELECT false STATUS, "User exists!" MESSAGE;
	ELSE
		SET found = 1;
		WHILE found > 0 DO
			SET token=(FLOOR(1 + (RAND() * 9223372036854775807)));
			SELECT count(id) FROM users WHERE id = token INTO found;
		END WHILE;
		INSERT INTO users (id, name, status) VALUES (token, newname, 'DISABLED');
		SET salt = substring(MD5(RAND()), -8);
		INSERT INTO shadow (uid, salt, password, type) 
			VALUES (token, salt, PASSWORD(CONCAT(salt, newpasswd)), 'LOGIN');
		SELECT true STATUS, token ID;
	END IF;
END $$

DELIMITER ;