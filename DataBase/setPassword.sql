-- -----------------------------------------------------
-- procedure setPassword
-- user password change function (not admin)
-- -----------------------------------------------------

USE `AnonID`;
DROP procedure IF EXISTS `setPassword`;
DELIMITER $$
USE `AnonID`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `setPassword`(
IN in_token BIGINT(20) UNSIGNED,
IN in_name VARCHAR(96),
IN in_oldpw VARCHAR(255),
IN in_newpw VARCHAR(255),
IN in_type ENUM('NORMAL', 'ADMIN', 'DURESS')
)
BEGIN
	DECLARE oldGood BOOLEAN;
	DECLARE newsalt CHAR(8); 
	
	/* Check Auth Token */
	/* Token MUST be NORMAL, log ADMIN or DURESS use! */
	
	/* Check old password */	
	SELECT count(*) INTO oldGood FROM authCookies ac 
		JOIN users u ON ac.userid = u.id
		JOIN shadow s ON s.uid = u.id
		WHERE ac.id = in_token
		AND password=PASSWORD(CONCAT(s.salt, in_oldpw));
		
	IF oldGood > 1 THEN
		SELECT "DATA INTEGRITY ERROR!" as ERROR;
	ELSEIF oldGood == 0 THEN
		SELECT "Passwords do not match!" as ERROR;
	END IF;
	
	/* Generate a new salt */
	SET newsalt = substring(MD5(RAND()), -8);

END$$

$$
DELIMITER ;
