package anonymous.id.server.AnonId.Database;

import java.io.Serializable;

public class AuthCookie implements Serializable {
	private Long login;
	private Long admin;
	private boolean duress;
	
	public AuthCookie(Long login, Long admin, boolean duress) {
		this.login = login;
		this.admin = admin;
		this.duress = duress;
	}

	public Long getAdmin() {
		return admin;
	}

	public boolean isDuress() {
		return duress;
	}
		
	public Long getLogin() {
		return login;
	}
	
	public void setAdmin(Long admin) {
		this.admin = admin;
	}
	
	public void setDuress(boolean duress) {
		this.duress = duress;
	}
	
	public void setLogin(Long login) {
		this.login = login;
	}

	public boolean isEnabled() {
		return (admin == null) ? false : true;
	}
}
