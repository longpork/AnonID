package anonymous.id.server.AnonId;

import java.sql.Connection;
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
 * @author longpork
 *
 */
public class DataStoreManager {
	
	Connection sqlCon;

	//XXX these can all probably become private once test harness 
	// is updated to use reflection
	// AuthCookie Types
	public static final String PWTYPE_LOGIN = "LOGIN";
	public static final String PWTYPE_ADMIN = "ADMIN";
	public static final String PWTYPE_DURESS = "DURESS";
	
	// SQL Strings
	public static final String sqlUserSetPassword = "call setPassword(?, ?, ?, ?)";
	public static final String sqlLogin = "call dblogin(?, ?)";
	public static final String sqlLogout = "call dblogout(?)";
	
	public DataStoreManager (Connection connection) {
		sqlCon = connection;
	}

	public void close() throws SQLException {
		sqlCon.close();
	}

}
