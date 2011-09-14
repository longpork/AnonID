package anonymous.id.server.AnonId.JUnit;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.DriverManager;
import java.util.ArrayList;
import java.util.Iterator;

import anonymous.id.server.AnonId.DataStoreManager;

import junit.framework.TestCase;

public class DataStoreManagerTest extends TestCase {
	// DB objects
	private Connection dbCon;
	private DataStoreManager dStore;
	
	// Test Strings
	private static final String goodLoginPasswd = "testlogin";
	private static final String goodDuressPasswd = "testduress";
	private static final String goodAdminPasswd = "testadmin";
	private static final String goodLoginName = "jtest";
		
	@Override
	protected void setUp() throws Exception {
		super.setUp();
		
		/* NEVER point this at a production DB
		 * NEVER create this user on a production DB
		 * Would be nice to have a tool that could init the db...
		 * then use that here */
		String DB_CONN_STRING = "jdbc:mysql://localhost:3306/AnonID";
		String DRIVER_CLASS_NAME = "com.mysql.jdbc.Driver";
	    String USER_NAME = "junit";
	    String PASSWORD  = "junit";
	    
	    Class.forName(DRIVER_CLASS_NAME).newInstance();
	    dbCon  = DriverManager.getConnection(DB_CONN_STRING, USER_NAME, PASSWORD);
	    dStore = new DataStoreManager(DriverManager.getConnection(DB_CONN_STRING, USER_NAME, PASSWORD));
	}
	
	@Override
	protected void tearDown() throws Exception {
		super.tearDown();
		dbCon.close();
		dStore.close();
	}
	
	public void testSQLConnection() throws Exception {
		assertTrue(dbCon.isValid(5));
	}
	
	public void testSQLBadLogin() throws Exception {
		PreparedStatement check = dbCon.prepareStatement(DataStoreManager.sqlLogin);
		check.setNString(1, goodLoginName);
		check.setNString(2, "FAIL!");
		ResultSet rs = check.executeQuery();

		assertTrue(rs.next());	
		assertTrue("STATUS".equals(rs.getMetaData().getColumnName(1)));
		assertFalse(rs.getBoolean("STATUS"));
		
		assertTrue("MESSAGE".equals(rs.getMetaData().getColumnName(2)));
		assertFalse(rs.next());
		rs.close();
		
		// ADMIN Password must not work for login
		check.setNString(1, goodLoginName);
		check.setNString(2, goodAdminPasswd);
		rs = check.executeQuery();
		
		assertTrue(rs.next());	
		assertTrue("STATUS".equals(rs.getMetaData().getColumnName(1)));
		assertFalse(rs.getBoolean("STATUS"));
		assertTrue("MESSAGE".equals(rs.getMetaData().getColumnName(2)));
		assertFalse(rs.next());
		rs.close();
		
	}
	
	public void testSQLGoodLogin() throws Exception {
		ResultSet rs = getSQLLoginResult(goodLoginName, goodLoginPasswd);

		// And we should have a good login
		assertTrue(rs.next());
		Boolean status = new Boolean(rs.getBoolean("STATUS"));
		if (! status.booleanValue() ) {
			fail(rs.getString("MESSAGE"));
		}
		long token = rs.getLong("TOKEN");
		rs.close();
		
		// Ok now logout
		logoutSQL(token);
	}
		
	public void testSQLUniqueAuthCookie() throws Exception {
		ArrayList<Long> cookies = new ArrayList<Long>();
		// Get login tokens.... they should all be unique
		for (int i=0; i < 500; ++i) {
			ResultSet rs;
			Long c;
			rs = getSQLLoginResult(goodLoginName, goodLoginPasswd);
			assertNotNull(rs);
			assertTrue(rs.next());
			assertTrue(rs.getBoolean("STATUS"));
			c = new Long(rs.getLong("TOKEN"));
			assertFalse(cookies.contains(c));
			cookies.add(c);
			rs.close();
		}
		
		// and logout... 10k times
		Iterator<Long> i = cookies.iterator();
		while(i.hasNext()) {
			logoutSQL(i.next());
		}
	}
	
	public void logoutSQL(Long c) throws Exception {
		PreparedStatement pslogin = dbCon.prepareStatement(DataStoreManager.sqlLogout);
		pslogin.setLong(1, c);
		assertFalse(pslogin.execute());
	}
	
	private ResultSet getSQLLoginResult(String name, String pw) throws Exception {
		PreparedStatement pslogin = dbCon.prepareStatement(DataStoreManager.sqlLogin);
		pslogin.setNString(1, name);
		pslogin.setNString(2, pw);
		return pslogin.executeQuery();
	}
	
	public ResultSet setSQLPasswordUser(long cookie, String oldpw, String newpw, String type) throws Exception {
		PreparedStatement pschange = dbCon.prepareStatement(DataStoreManager.sqlUserSetPassword);
		pschange.setLong(1, cookie);
		pschange.setString(2, oldpw);
		pschange.setString(3, newpw);
		pschange.setString(4, type);
		return pschange.executeQuery();
	}
	
	public void testSQLUserPasswordChange() throws Exception {
		String testPasswd = "000testPasswd000";
		// Login to get an auth cookie
		ResultSet rs = getSQLLoginResult(goodLoginName, goodLoginPasswd);
		assertNotNull(rs);
		assertTrue(rs.next());
		Long cookie = new Long(rs.getLong("TOKEN"));
		assertFalse(rs.next());
		rs.close();
		
		// Attempt change to same as duress
		rs = setSQLPasswordUser(cookie, goodLoginPasswd, goodDuressPasswd, DataStoreManager.PWTYPE_LOGIN);
		assertNotNull(rs);
		assertTrue(rs.next());
		assertFalse(new Boolean(rs.getBoolean("STATUS")));
		
		// change the password
		rs = setSQLPasswordUser(cookie, goodLoginPasswd, testPasswd, DataStoreManager.PWTYPE_LOGIN);
		assertNotNull(rs);
		assertTrue(rs.next());
		assertTrue(new Boolean(rs.getBoolean("STATUS")));
		
		// change back
		rs = setSQLPasswordUser(cookie, testPasswd, goodLoginPasswd, DataStoreManager.PWTYPE_LOGIN);
		assertNotNull(rs);
		assertTrue(rs.next());
		assertTrue(new Boolean(rs.getBoolean("STATUS")));
		
	}
	
	public void testSQLAdminCreateUser() throws Exception {
		
		// Login? again? this needs extracting!
		ResultSet rs = getSQLLoginResult(goodLoginName, goodLoginPasswd);
		assertNotNull(rs);
		assertTrue(rs.next());
		Long cookie = new Long(rs.getLong("TOKEN"));
		assertFalse(rs.next());
		rs.close();
		
		// Enable admin functions
		ResultSet rs = DataStoreManager.enableSQLAdmin(cookie, goodAdminPasswd);
		assertNotNull(rs);
		assertTrue(rs.next());
		Long adminc = new Long(rs.getLong("TOKEN"));
		assertFalse(rs.next());
		rs.close();

		// Create the user
		ResultSet rs = adminSQLCreateUser();
	}
	
	
}
