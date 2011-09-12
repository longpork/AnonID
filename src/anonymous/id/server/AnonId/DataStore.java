package anonymous.id.server.AnonId;

import java.sql.Connection;
import java.sql.SQLException;

public class DataStore {
	
	Connection sqlCon;

	// AuthCookie Types
	public static final String PWTYPE_LOGIN = "LOGIN";
	public static final String PWTYPE_ADMIN = "LOGIN";
	public static final String PWTYPE_DURESS = "LOGIN";
	
	// SQL Strings
	public static final String sqlUserSetPassword = "call setPassword(?, ?, ?, ?)";
	public static final String sqlLogin = "call dblogin(?, ?)";
	public static final String sqlLogout = "call dblogout(?)";
	
	public DataStore (Connection connection) {
		sqlCon = connection;
	}

	public void close() throws SQLException {
		sqlCon.close();
	}

}
