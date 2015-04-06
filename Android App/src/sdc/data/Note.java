package sdc.data;

public class Note {
	private int id;
	private String title;
	private String content;
	private long time;
	private int ownerId;
	private int serverId;
	private int tripId;
	private int flag;
	private User ownerInfo;

	public Note(int id, String title, String content, long time, int userId) {
		super();
		this.id = id;
		this.title = title;
		this.content = content;
		this.time = time;
		this.ownerId = userId;
	}

	public Note(int id, String title, String content, long time, int ownerId,
			int serverId, int tripId, int flag) {
		super();
		this.id = id;
		this.title = title;
		this.content = content;
		this.time = time;
		this.ownerId = ownerId;
		this.serverId = serverId;
		this.tripId = tripId;
		this.flag = flag;
	}

	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	public String getContent() {
		return content;
	}

	public void setContent(String content) {
		this.content = content;
	}

	public long getTime() {
		return time;
	}

	public void setTime(long time) {
		this.time = time;
	}

	public int getOwnerId() {
		return ownerId;
	}

	public void setOwnerId(int userId) {
		this.ownerId = userId;
	}

	public int getServerId() {
		return serverId;
	}

	public void setServerId(int serverId) {
		this.serverId = serverId;
	}

	public int getTripId() {
		return tripId;
	}

	public void setTripId(int tripId) {
		this.tripId = tripId;
	}

	public int getFlag() {
		return flag;
	}

	public void setFlag(int flag) {
		this.flag = flag;
	}

	public User getOwnerInfo() {
		return ownerInfo;
	}

	public void setOwnerInfo(User ownerInfo) {
		this.ownerInfo = ownerInfo;
	}

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

}
