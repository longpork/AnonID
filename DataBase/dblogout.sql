-- -----------------------------------------------------
-- procedure dblogout
-- -----------------------------------------------------

USE `AnonID`;
DROP procedure IF EXISTS `dblogout`;
DELIMITER $$
USE `AnonID`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `dblogout`(
IN lc BIGINT(20)
)
BEGIN
	DECLARE rcount INT;
	DELETE FROM authCookies WHERE id=lc;
	
	SET rcount = ROW_COUNT();
	if (rcount < 1) THEN
		SELECT false STATUS, "Login cookie not found!" MESSAGE;
	ELSEIF (rcount = 1) THEN
		SELECT true STATUS;
	END IF;
END $$

$$
DELIMITER ;

