-- -----------------------------------------------------
-- procedure dblogout
-- -----------------------------------------------------

USE `AnonID`;
DROP procedure IF EXISTS `dblogout`;
DELIMITER $$
USE `AnonID`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `dblogout`(
IN cookie BIGINT(20)
)
BEGIN
	DELETE FROM authCookies WHERE id=cookie;
END $$

$$
DELIMITER ;

