-- -----------------------------------------------------
-- procedure adminLockUser
-- -----------------------------------------------------

USE `AnonID`;
DROP procedure IF EXISTS `adminLockUser`;
DELIMITER $$
USE `AnonID`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `adminLockUser`(
IN lc BIGINT(20),
IN ec BIGINT(20),
IN uname VARCHAR(96),
IN comment TEXT
)
BEGIN
	DECLARE updated INT;
	
	IF (authCookieIsEnabled(lc, ec)) THEN
		UPDATE users SET status = 'LOCKED' WHERE name = uname;
		SELECT ROW_COUNT() INTO updated;
		IF (updated > 1) THEN
			SELECT false STATUS, "Internal Error!" MESSAGE;
		ELSEIF (updated < 1) THEN
			SELECT false STATUS, "User does not exist!" MESSAGE;
		ELSE
			/* XXX We don't use comment yet... should log it here */
			SELECT true STATUS;
		END IF;
	ELSE
		SELECT false STATUS, "User Lock Denied. Insufficient privileges.";
	END IF;
END $$

DELIMITER ;