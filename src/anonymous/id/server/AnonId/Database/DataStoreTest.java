package anonymous.id.server.AnonId.Database;

import java.sql.Connection;
import java.sql.DriverManager;

import javax.security.auth.login.LoginException;

import junit.framework.TestCase;

public class DataStoreTest extends TestCase {
	private Connection sqlCon;
	private DataStore dStore;

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
		 * NEVER point this at a production DB NEVER create this user on a
		 * production DB Would be nice to have a tool that could init the db...
		 * then use that here ...a DataStoreManager
		 */

		String DB_CONN_STRING = "jdbc:mysql://localhost:3306/AnonID";
		String DRIVER_CLASS_NAME = "com.mysql.jdbc.Driver";
		String USER_NAME = "junit";
		String PASSWORD = "junit";

		Class.forName(DRIVER_CLASS_NAME).newInstance();

		dStore = new DataStore(DriverManager.getConnection(DB_CONN_STRING,
				USER_NAME, PASSWORD));
	}
	
	public void testLoginGood() throws Exception {
		// Good Login
		AuthCookie ac = dStore.login(goodLoginName, goodLoginPasswd);
		dStore.logout(ac);
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
		assertNotNull(ac);
		assertFalse(ac.isEnabled());
		dStore.enable(ac, goodAdminPasswd);
		assertTrue(ac.isEnabled());
		assertTrue(dStore.isEnabled(ac));
		dStore.disable(ac);
		dStore.logout(ac);
	}
	
	public void testAdminCreateUser() throws Exception {
		AuthCookie ac = dStore.login(goodLoginName, goodLoginPasswd);
		dStore.enable(ac, goodAdminPasswd);
		dStore.adminCreateUser(ac, newLogin, newPasswd);
		dStore.disable(ac);
		dStore.logout(ac);
	}

}
