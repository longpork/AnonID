package anonymous.id.server.AnonId.Database;

public class DataStoreException extends Exception {
	private static final long serialVersionUID = 1L;
	private String Message;
	public DataStoreException(String string) {
		Message = string;
	}
	
	@Override
	public String getMessage() {
		return Message;
	}

}
