package anonymous.id.server.AnonId.JUnit;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import java.sql.DriverManager;

import javax.sql.DataSource;

import anonymous.id.server.AnonId.DataStore;

import junit.framework.TestCase;

public class DataStoreTest extends TestCase {

	private static final String sqlCheck = "call dblogin(?, ?)";
	
	private Connection dbCon;
	private DataStore dStore;
	
	@Override
	protected void setUp() throws Exception {
		super.setUp();
		
		/* never point this at a production DB */
		/* never create this user on a production DB */
		String DB_CONN_STRING = "jdbc:mysql://localhost:3306/AnonID";
		String DRIVER_CLASS_NAME = "com.mysql.jdbc.Driver";
	    String USER_NAME = "junit";
	    String PASSWORD  = "junit";
	    
	    Class.forName(DRIVER_CLASS_NAME).newInstance();
	    dbCon  = DriverManager.getConnection(DB_CONN_STRING, USER_NAME, PASSWORD);
	    dStore = new DataStore(DriverManager.getConnection(DB_CONN_STRING, USER_NAME, PASSWORD));
	}
	
	@Override
	protected void tearDown() throws Exception {
		// TODO Auto-generated method stub
		super.tearDown();
		dbCon.close();
		dStore.close();
	}
	
	public void testConnection() throws Exception {
		assertTrue(dbCon.isValid(5));
	}
	
	public void testSQLBadLogin() throws Exception {
		PreparedStatement check = dbCon.prepareStatement(sqlCheck);
		check.setNString(1, "jtest");
		check.setNString(2, "FAIL!");
		ResultSet rs = check.executeQuery();

		// There MUST be a response row of some sort
		assertTrue(rs.next());	
		assertTrue("STATUS".equals(rs.getMetaData().getColumnName(1)));
		assertTrue("MESSAGE".equals(rs.getMetaData().getColumnName(2)));
		assertFalse(rs.getBoolean("STATUS"));
		assertFalse(rs.next());
		rs.close();
	}
	
	public void testSQLGoodLogin() throws Exception {
		PreparedStatement check = dbCon.prepareStatement(sqlCheck);
		check.setNString(1, "jtest");
		check.setNString(2, "testlogin");
		ResultSet rs = check.executeQuery();

		// And we should have a good login
		assertTrue(rs.next());
		assertTrue(rs.getBoolean("STATUS"));
		int token = rs.getInt("TOKEN");
		rs.close();

	}

}
