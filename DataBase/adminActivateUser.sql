-- -----------------------------------------------------
-- procedure adminActivateUser
-- -----------------------------------------------------

USE `AnonID`;
DROP procedure IF EXISTS `adminActivateUser`;
DELIMITER $$
USE `AnonID`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `adminActivateUser`(
IN lc BIGINT(20),
IN ec BIGINT(20),
IN uname VARCHAR(96)
)
BEGIN
	IF (authCookieIsEnabled(lc, ec)) THEN
		UPDATE users
			SET status='ACTIVE'
			WHERE name=uname AND status != 'LOCKED';
		IF (ROW_COUNT() = 1) THEN
			SELECT true STATUS;
		ELSE
			/* ROW_COUNT() != 1 !?!
			 * This should be split 
			 * 0 = unknown user
			 * 1 = Database Consistency error! */
			SELECT false STATUS, "ROW_COUNT() != 1" MESSAGE;
		END IF;
	ELSE
		SELECT false STATUS, "Invalid Auth Cookie" MESSAGE;
	END IF;
END 