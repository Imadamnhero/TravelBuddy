package sdc.data;

public class User {
	private int id;
	private String avatar;
	private String name;
	private int tripId;
	private String tripName;

	public User(int id, String avatar, String name, int tripId, String tripName) {
		super();
		this.id = id;
		this.avatar = avatar;
		this.name = name;
		this.tripId = tripId;
		this.tripName = tripName;
	}

	public User(int id, String avatar, String name, int tripId) {
		super();
		this.id = id;
		this.avatar = avatar;
		this.name = name;
		this.tripId = tripId;
	}

	public User(int id, String avatar, String name) {
		super();
		this.id = id;
		this.avatar = avatar;
		this.name = name;
	}

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public String getAvatar() {
		return avatar;
	}

	public void setAvatar(String avatar) {
		this.avatar = avatar;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public int getTripId() {
		return tripId;
	}

	public void setTripId(int tripId) {
		this.tripId = tripId;
	}

	public String getTripName() {
		return tripName;
	}

	public void setTripName(String tripName) {
		this.tripName = tripName;
	}

}
