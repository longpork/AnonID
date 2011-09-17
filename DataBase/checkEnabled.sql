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
	SELECT (authCookieIsValid(lc) && authCookieIsValid(ec)) STATUS
	FROM (SELECT * FROM authCookies WHERE id = lc AND type = 'LOGIN') lct
	JOIN (SELECT * FROM authCookies WHERE id = ec AND type = 'ADMIN') ect
	ON lct.userid = ect.userid;
END $$

DELIMITER ;