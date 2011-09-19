package anonymous.id.server.AnonId.Database;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import javax.security.auth.login.LoginException;

import junit.framework.TestCase;

public class DataStoreTest extends TestCase {
	private Connection sqlCon;
	private DataStore dStore;

	// Stuff to clean up
	Long newUid;
	AuthCookie ac;
	
	// Test Constants
	private static final String goodLoginPasswd = "testlogin";
	private static final String goodDuressPasswd = "testduress";
	private static final String goodAdminPasswd = "testadmin";
	private static final String goodLoginName = "jtest";
	private static final String newLogin = "jtestnew";
	private static final String newPasswd = "jtestnewlogin";
	private static final String newDuress = "jtestnewduress";
	private static final String newAdmin = "jtestnewadmin";

	@Override
	protected void setUp() throws Exception {
		super.setUp();
		
		/*
		 * Make a database connection, and add a test user that can be used in tests.
		 *
		 * NEVER point this at a production DB NEVER create this user on a
		 * production DB Would be nice to have a tool that could init the DB...
		 * then use that here ...a DataStoreManager maybe?
		 */
		String DB_CONN_STRING = "jdbc:mysql://localhost:3306/AnonID";
		String DRIVER_CLASS_NAME = "com.mysql.jdbc.Driver";
		String USER_NAME = "junit";
		String PASSWORD = "junit";

		Class.forName(DRIVER_CLASS_NAME).newInstance();

		sqlCon = DriverManager.getConnection(DB_CONN_STRING, USER_NAME, PASSWORD);
		dStore = new DataStore(sqlCon);
		
		// XXX could cleanup and use string vars for readability
		sqlCon.prepareStatement(
				"insert into users (id, name, status) values (100, 'jtest', 'ACTIVE')").execute();
		sqlCon.prepareStatement(
				"insert into shadow (uid, salt, password, type) VALUES (100, 'j&^90yyy', PASSWORD('j&^90yyytestlogin'), 'LOGIN')"
		).execute();
		sqlCon.prepareStatement(
			"insert into shadow (uid, salt, password, type) VALUES (100, 'jh&^9yyy', PASSWORD('jh&^9yyytestduress'), 'DURESS')"
		).execute();
		sqlCon.prepareStatement(
			"insert into shadow (uid, salt, password, type) VALUES (100, 'jh&^90yy', PASSWORD('jh&^90yytestadmin'), 'ADMIN')"
		).execute();
	}
	
	public void testLoginGood() throws Exception {
		// Good Login
		ac = dStore.login(goodLoginName, goodLoginPasswd);
	}
	
	public void testLoginBad() throws Exception {
		String loginFail = null;
		// Bad Password
		try {
			dStore.login(goodLoginName, "badpass");
			fail("Bad Password did not throw an exception!");
		} catch (LoginException e) {
			loginFail = e.getMessage();
		}

		// Bad user
		try {
			dStore.login("::nobody", "badpass");
			fail("Bad Password did not throw an exception!");
		} catch (LoginException e) {
			// prevent user name harvesting
			assertEquals(loginFail, e.getMessage());
		}
	}
	
	public void testEnable() throws Exception {
		AuthCookie ac = dStore.login(goodLoginName, goodLoginPasswd);
		assertFalse(ac.isEnabled());
		dStore.enable(ac, goodAdminPasswd);
		assertTrue(ac.isEnabled());
		assertTrue(dStore.isEnabled(ac));
	}
	
	public void testAdminCreateUser() throws Exception {
		AuthCookie ac = dStore.login(goodLoginName, goodLoginPasswd);
		dStore.enable(ac, goodAdminPasswd);		
		
		// Create the User
		newUid = new Long(dStore.adminCreateUser(ac, newLogin, newPasswd));
		dStore.adminActivateUser(ac, newLogin);
		
		// Login as the new User
		AuthCookie testac = dStore.login(newLogin, newPasswd);
		dStore.logout(testac);
	}
	
	public void testAdminLockUser() throws SQLException, DataStoreException, LoginException {
		AuthCookie ac = dStore.login(goodLoginName, goodLoginPasswd);
		dStore.enable(ac, goodAdminPasswd);		

		// Create the User
		newUid = new Long(dStore.adminCreateUser(ac, newLogin, newPasswd));
		dStore.adminActivateUser(ac, newLogin);

		// Login as the new User
		AuthCookie testac = dStore.login(newLogin, newPasswd);
		dStore.logout(testac);

		// Lock the user
		dStore.adminLockUser(ac, newLogin, "JUnit Testing: testAdminLockUser()");
		AuthCookie lockac = null;
		try {
			lockac = dStore.login(newLogin, newPasswd);
			fail("Login worked! Should be a locked account!");
		} catch (LoginException e) {
			assertTrue(true);
		} catch (SQLException e) {
			fail(e.getLocalizedMessage());
		}
		assertNull(lockac);
	}
	
	@Override
	protected void tearDown() throws Exception {
		super.tearDown();

		// Quick and Dirty cleanup
		sqlCon.prepareStatement("DELETE from authCookies").execute();				
		sqlCon.prepareStatement("DELETE from shadow WHERE uid = 100").execute();
		sqlCon.prepareStatement("DELETE from users WHERE id = 100").execute();		

		// Clean up the new user
		if (newUid != null) {
			PreparedStatement ps = sqlCon.prepareStatement("DELETE from shadow WHERE uid = ?");
			ps.setLong(1, newUid);
			ps.execute();
			ps = sqlCon.prepareStatement("DELETE from users WHERE id = ?");
			ps.setLong(1, newUid);
			ps.execute();
		}
	}
}
