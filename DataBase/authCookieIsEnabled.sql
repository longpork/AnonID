-- -----------------------------------------------------
-- function authCookieIsEnabled
-- Checks the validity of an authCookie. 
-- Does NOT check cookie type!
-- Return
--      0 - Cookie is expired or does not exist
--      1 - Cookie exists and is still valid
-- -----------------------------------------------------

USE `AnonID`;
DROP function IF EXISTS `authCookieIsEnabled`;
DELIMITER $$
USE `AnonID`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `authCookieIsEnabled`(
lc BIGINT(20) UNSIGNED,
ec BIGINT(20) UNSIGNED
) RETURNS tinyint(1)
BEGIN
	DECLARE ret BOOLEAN;
	
	SELECT (authCookieIsValid(lc) && authCookieIsValid(ec)) INTO ret
	FROM (SELECT * FROM authCookies WHERE id = lc AND type = 'LOGIN') lct
	JOIN (SELECT * FROM authCookies WHERE id = ec AND type = 'ADMIN') ect
	ON lct.userid = ect.userid;
	
	RETURN ret;
END $$
DELIMITER ;
