-- -----------------------------------------------------
-- function authCookieIsValid
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
	SELECT IF((ac.created + (ac.lifetime * INTERVAL '1 second') < CURRENT_TIMESTAMP), 1, 0)
		INTO acCurrent
		FROM authCookies ac
		WHERE ac.id = cookie;
	RETURN acCurrent;
END$$

$$
DELIMITER ;