-- -----------------------------------------------------
-- function authCookieIsValid
-- Checks the validity of an authCookie. 
-- Return
--      0 - Cookie is expired or does not exist
--      1 - Cookie exists and is still valid
-- -----------------------------------------------------

USE `AnonID`;
DROP function IF EXISTS `authCookieIsValid`;
DELIMITER $$
USE `AnonID`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `authCookieIsValid`(
cookie BIGINT(20) UNSIGNED
) RETURNS tinyint(1)
BEGIN
	DECLARE acCurrent BOOLEAN;
	SELECT IF((TIMESTAMPADD(MINUTE, ac.lifetime, ac.created) > CURRENT_TIMESTAMP), 1, 0)
		INTO acCurrent
		FROM authCookies ac
		WHERE ac.id = cookie;
	RETURN IF(isNULL(acCurrent), 0, acCurrent);
END$$

$$
DELIMITER ;
