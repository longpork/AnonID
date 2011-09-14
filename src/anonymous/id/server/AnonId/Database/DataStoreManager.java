package anonymous.id.server.AnonId.Database;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * DataStoreManager is a stub for a tool class that can be used for
 * database updates. To be used, it will require a connection with 
 * DBA level access.
 * 
 * Until it exists, its main purpose is to serve as a placeholder class
 * to support unit tests for the stored procedures that it will eventuallty
 * be used to manage/upgrade.
 *  
 * 
 * @author longpork < XXX need email address >
 * 
 */
public class DataStoreManager {
	
	private Connection sqlCon;

	// AuthCookie Types
	static final String PWTYPE_LOGIN = "LOGIN";
	static final String PWTYPE_ADMIN = "ADMIN";
	static final String PWTYPE_DURESS = "DURESS";
	
	// SQL Strings
	static final String sqlUserSetPassword = "call setPassword(?, ?, ?, ?)";
	static final String sqlLogin = "call dblogin(?, ?)";
	static final String sqlLogout = "call dblogout(?)";
	static final String sqlEnable = "call enable(?, ?)";
	
	public DataStoreManager (Connection connection) {
		sqlCon = connection;
	}

	public void close() throws SQLException {
		sqlCon.close();
	}
	
	/* SQL functions are thin wrappers for stored procedures. Package
	 * access allowed for unit testing of database procedures. */

	/**
	 * Unlock the use of administrative functions that are available to 
	 * the logged in user. 
	 * @param ac the user's login cookie
	 * @param pw the user's admin password
	 * @return ResultSet containing a single row with a boolean 
	 * 'SUCCESS' and Long 'TOKEN' if successful or a String 'ERROR'
	 * if not.
	 * @throws SQLException 
	 */
	ResultSet enableSQLAdmin(Long ac, String pw) throws SQLException {
		PreparedStatement psenable = sqlCon.prepareStatement(sqlEnable);
		return null;
	}

	static ResultSet adminSQLCreateUser(Long cookie, Long adminc,
			String newlogin, String newpasswd) {
		// TODO Auto-generated method stub
		return null;
	}

}
