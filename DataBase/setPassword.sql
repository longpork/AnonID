-- -----------------------------------------------------
-- procedure setPassword
-- user password change function (not admin)
-- -----------------------------------------------------

USE `AnonID`;
DROP procedure IF EXISTS `setPassword`;
DELIMITER $$
USE `AnonID`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `setPassword`(
IN cookie BIGINT(20) UNSIGNED,
IN oldpw VARCHAR(255),
IN newpw VARCHAR(255),
IN pwtype ENUM('LOGIN', 'ADMIN', 'DURESS')
)
BEGIN
	DECLARE pwcheck BOOLEAN;
	DECLARE newsalt CHAR(8); 
	DECLARE acType ENUM('LOGIN', 'ADMIN', 'DURESS');
	DECLARE doChange BOOLEAN;
	DECLARE uid BIGINT(20);
	DECLARE matches INT;
	DECLARE message TEXT;
	
	/* Check Auth Token is valid, get its type if it is */
	IF (authCookieIsValid(cookie)) THEN
		SELECT ac.type
			INTO acType
			FROM authCookies ac 
			JOIN users u ON ac.userid = u.id
			JOIN shadow s ON s.uid = u.id
			WHERE ac.id = cookie AND s.type = pwtype;
	END IF;

	/* handle cookie types */
	SET doChange = false;
	IF (actype = 'LOGIN') THEN
		SELECT IF(s.password=PASSWORD(CONCAT(s.salt, oldpw)), true, false),ac.type,u.id
			INTO doChange,acType,uid
			FROM authCookies ac 
			JOIN users u ON ac.userid = u.id
			JOIN shadow s ON s.uid = u.id
			WHERE ac.id = cookie AND s.type = pwtype;
			IF (doChange = false) THEN
				SET message="Invalid Credentials!";
			END IF;
	ELSEIF (ac.type = 'DURESS') THEN
		/* XXX: log Here! - what else? */
		/* XXX: continue the deception... use duress password for login change? */
		/* XXX: or ....error generically? */
		SET doChange = false;
		SET message  = "Invalid Auth Cookie Type!";
	ELSE
		SET doChange = false;
		SET message  = "Invalid Auth Cookie Type!";
	END IF;

	/* Last Check: This password can't be the same as any others! duh!*/
	IF (doChange) THEN
		SELECT COUNT(*) INTO matches
			FROM shadow s 
			WHERE s.uid=uid AND s.password=PASSWORD(CONCAT(s.salt, newpw));

		IF (matches != 0) THEN
			SET doChange = false;
			SET message="All passwords must be unique for each user!";
		END IF;
	END IF;
	
	/* do the update, or send an error */
	IF (doChange = true) THEN
		/* mmm make mine salty */
		SET newsalt = substring(MD5(RAND()), -8);
		UPDATE shadow s
			SET s.salt=newsalt,s.password = PASSWORD(CONCAT(newsalt, newpw))
			WHERE s.uid=uid AND s.password = PASSWORD(CONCAT(s.salt, oldpw));
			SELECT true STATUS;
	ELSE
		SELECT false STATUS, message ERROR;
	END IF;
END$$

$$
DELIMITER ;
