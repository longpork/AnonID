/**
 * 
 */
package anonymous.id.server.AnonId.Database;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import javax.security.auth.login.LoginException;

/**
 * @author longpork
 *
 */
public class DataStore {


	private static final String RESULT_ID = "ID";

	private Connection sqlCon;

	
	// SQL Strings
	private static final String sqlAdminActivateUser = "call adminActivateUser(?, ?, ?)";
	private static final String sqlAdminCreateUser   = "call adminCreateUser(?, ?, ?, ?)";
	private static final String sqlCheckEnabled      = "call checkEnabled(?, ?)";
	private static final String sqlDisable           = "call disable(?, ?)";
	private static final String sqlEnable            = "call enable(?, ?)";
	private static final String sqlAdminLockUser     = "CALL adminLockUser(?, ?, ?, ?)";
	private static final String sqlLogin             = "call dblogin(?, ?)";
	private static final String sqlLogout            = "call dblogout(?)";
	private static final String sqlUserSetPassword   = "call setPassword(?, ?, ?, ?)";
	
	private static final String RESULT_ERROR = "MESSAGE";
	private static final String RESULT_STATUS = "STATUS";

	// AuthCookie Types
	static final String PWTYPE_LOGIN = "LOGIN";
	static final String PWTYPE_ADMIN = "ADMIN";
	static final String PWTYPE_DURESS = "DURESS";

	// ERROR String
	private static final String ERR_INTERNAL = "Internal Error! Please try again later.";
	
	public DataStore(Connection sql) {
		sqlCon = sql;
	}

	public AuthCookie login(String name, String pass) throws LoginException, SQLException {
		PreparedStatement pslogin = sqlCon.prepareStatement(sqlLogin);
		pslogin.setString(1, name);
		pslogin.setString(2, pass);
		
		ResultSet rs =  makeSQLCall(pslogin);
		// It must be valid
		if (! rs.getBoolean(RESULT_STATUS)) {
			throw new LoginException(rs.getString(RESULT_ERROR));
		}
		
		long lc = rs.getLong("TOKEN");
		if (rs.wasNull()) {
			// XXX log! if we got here this shouldn't be null
			throw new SQLException(ERR_INTERNAL);
		}
		return new AuthCookie(lc, null, false);
	}

	public void logout(AuthCookie ac) throws SQLException, DataStoreException {
		if (ac == null) {
			throw new NullPointerException();
		} else if (ac.isEnabled()) {
			this.disable(ac);
		}
		// Now disable the login cookie
		PreparedStatement pslogin = sqlCon.prepareStatement(sqlLogout);
		pslogin.setLong(1, ac.getLogin());

		ResultSet rs =  makeSQLCall(pslogin);
		if (! rs.getBoolean(RESULT_STATUS)) {
			throw new DataStoreException(rs.getString(RESULT_ERROR));
		}
	}

	public void enable(AuthCookie ac, String pass) throws SQLException, LoginException {
		PreparedStatement ps = sqlCon.prepareStatement(sqlEnable);
		ps.setLong(1, ac.getLogin());
		ps.setString(2, pass);
		ResultSet rs = makeSQLCall(ps);
		// It must be valid
		if (! rs.getBoolean(RESULT_STATUS)) {
			throw new LoginException(rs.getString(RESULT_ERROR));
		}
		
		long ec = rs.getLong("TOKEN");
		
		if (rs.wasNull()) {
			// XXX log! if we got here this shouldn't be null
			throw new SQLException(ERR_INTERNAL);
		}
		
		ac.setAdmin(ec);
	}

	public void disable(AuthCookie ac) throws DataStoreException, SQLException {
		if (ac != null && ac.isEnabled()) {
			PreparedStatement ps = sqlCon.prepareStatement(sqlDisable);
			ps.setLong(1, ac.getLogin());
			ps.setLong(2, ac.getAdmin());
			ResultSet rs = makeSQLCall(ps);
			if (! rs.getBoolean(RESULT_STATUS)) {
				throw new DataStoreException(rs.getString(RESULT_ERROR));
			}
			ac.setAdmin(null);
		} else if (ac == null) {
			throw new NullPointerException();
		} 
	}

	public long adminCreateUser(AuthCookie ac, String newlogin, String newpasswd) throws SQLException {
		PreparedStatement ps = sqlCon.prepareStatement(sqlAdminCreateUser);
		ps.setLong(1, ac.getLogin());
		ps.setLong(2, ac.getAdmin());
		ps.setString(3, newlogin);
		ps.setString(4, newpasswd);
		ResultSet rs = makeSQLCall(ps);
		return rs.getLong(RESULT_ID);
	}

	public boolean isEnabled(AuthCookie ac) throws SQLException {
		PreparedStatement ps = sqlCon.prepareStatement(sqlCheckEnabled);
		// XXX Nothing to validate? Really? Should this throw?
		if (! ac.isEnabled()) { return false; }
		ps.setLong(1, ac.getLogin());
		ps.setLong(2, ac.getAdmin());
		ResultSet rs = makeSQLCall(ps); 
		return rs.getBoolean(RESULT_STATUS);
	}

	/**
	 * Internal method to make and validate an SQL prepared statement,
	 * and check response. Makes sure the response conforms to our call
	 * standard format.
	 * @param ps
	 * @return
	 * @throws SQLException
	 */
	private ResultSet makeSQLCall(PreparedStatement ps) throws SQLException {
		ResultSet rs = ps.executeQuery();
	
		// This call is working... right?
		if (rs == null || ! rs.next()) { 
			// TODO log this as it should never happen!
			throw new SQLException(ERR_INTERNAL); 
		}
		
		// Status can't be null either
		rs.getBoolean(RESULT_STATUS);
		if (rs.wasNull()) {
			// TODO log here too
			throw new SQLException(ERR_INTERNAL);
		} else if (rs.next()) {
			// TODO and log
			throw new SQLException(ERR_INTERNAL);
		}
		
		// Set to the first row
		rs.first();
		return rs;
	}

	public void adminActivateUser(AuthCookie ac, String uname) throws SQLException, DataStoreException {
		PreparedStatement ps = sqlCon.prepareStatement(sqlAdminActivateUser);
		if (ac == null) {
			throw new DataStoreException("Null Authcookie!");
		}
		ps.setLong(1, ac.getLogin());
		ps.setLong(2, ac.getAdmin());
		ps.setString(3, uname);
		ResultSet rs = makeSQLCall(ps);
		
		if (! rs.getBoolean(RESULT_STATUS)) {
			throw new DataStoreException("Unable to activate user: " + rs.getString(RESULT_ERROR));
		}
	}

	public void adminLockUser(AuthCookie ac, String uname, String comment) throws SQLException, DataStoreException {
		PreparedStatement ps = sqlCon.prepareStatement(sqlAdminLockUser);
		ps.setLong(1, ac.getLogin());
		ps.setLong(2, ac.getAdmin());
		ps.setString(3, uname);
		ps.setString(4, comment);
		ResultSet rs = makeSQLCall(ps);
		
		if (! rs.getBoolean(RESULT_STATUS)) {
			throw new DataStoreException("Unable to activate user: " + rs.getString(RESULT_ERROR));
		}
	}
	
	
	
}
