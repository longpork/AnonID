package anonymous.id.server.AnonId;

import java.sql.Connection;
import java.sql.SQLException;

public class DataStore {
	
	Connection sqlCon;

	public DataStore (Connection connection) {
		sqlCon = connection;
	}

	public void close() throws SQLException {
		sqlCon.close();
	}

}
