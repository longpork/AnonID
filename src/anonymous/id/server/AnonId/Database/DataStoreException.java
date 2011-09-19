package anonymous.id.server.AnonId.Database;

public class DataStoreException extends Exception {
	private String Message;
	public DataStoreException(String string) {
		Message = string;
	}

}
