-- -----------------------------------------------------
-- procedure checkEnabled
-- -----------------------------------------------------

USE `AnonID`;
DROP procedure IF EXISTS `checkEnabled`;
DELIMITER $$
USE `AnonID`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `checkEnabled`(
IN lc BIGINT(20),
IN ec BIGINT(20)
)
BEGIN
	SELECT authCookieIsEnabled(lc, ec) STATUS;
END $$

DELIMITER ;