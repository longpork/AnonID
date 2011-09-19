package anonymous.id.server.AnonId.Database;

import junit.framework.Test;
import junit.framework.TestSuite;

public class AllDatabaseTests {

	public static Test suite() {
		TestSuite suite = new TestSuite(AllDatabaseTests.class.getName());
		//$JUnit-BEGIN$
		suite.addTestSuite(DataStoreTest.class);
		//$JUnit-END$
		return suite;
	}

}
