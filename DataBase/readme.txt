AnonID Database ReadMe

Origin:

This file was originally created from an export from Mysql Workbench. 

Design Considerations

1. All application access is via stored procedures and functions. 
2. User may have different passwords for different types of access(normal|admin|duress)
3. All login processing is via procedure dblogin, which provides an authCookie token.
4. All procedures and functions which require user level access, require 
   a valid authcookie token
5. All database row id values are BIGINT and randomly generated. 

Function/Procedure Reference

	Public Interface
	
	dblogin - process login; if successful, return authCookie token and token type
	setPassword - user level password function. Requires a login type authCookie. 
	
	Internal Functions
	
	authCookieIsValid - return true if the cookie exists in the table and has not expired


TODO

* Bring back admin pw type, but only support its use when admin functions are called for
* functions should always make sure that the proper type of cookie is passed.
* Current work authCookieIsValid and setPassword 