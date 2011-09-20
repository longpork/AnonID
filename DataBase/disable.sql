-- -----------------------------------------------------
-- procedure disable
-- -----------------------------------------------------

USE `AnonID`;
DROP procedure IF EXISTS `disable`;
DELIMITER $$
USE `AnonID`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `disable`(
IN lc BIGINT(20),
IN ec BIGINT(20)
)
BEGIN
	DECLARE updated INT;
	IF (authCookieIsEnabled(lc, ec)) THEN
		DELETE FROM authCookies WHERE id=ec && type='ADMIN';
	END IF;
	SET updated = ROW_COUNT();
	IF (updated=1) THEN
		SELECT true STATUS;
	ELSEIF (updated < 1) THEN
		SELECT false STATUS, "Invalid AuthCookie" MESSAGE;
	END IF;
END $$

$$
DELIMITER ;

