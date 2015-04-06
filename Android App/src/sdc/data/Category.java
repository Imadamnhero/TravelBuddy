package sdc.data;

public class Category {
	private int id;
	private String nameCate;
	private int color;
	private int localId;
	private int flag;
	private int userId;

	public Category(int id, String nameCate) {
		super();
		this.id = id;
		this.nameCate = nameCate;
	}

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public String getNameCate() {
		return nameCate;
	}

	public void setNameCate(String nameCate) {
		this.nameCate = nameCate;
	}

	public int getColor() {
		return color;
	}

	public void setColor(int color) {
		this.color = color;
	}

	public int getLocalId() {
		return localId;
	}

	public void setLocalId(int localId) {
		this.localId = localId;
	}

	public int getFlag() {
		return flag;
	}

	public void setFlag(int flag) {
		this.flag = flag;
	}

	public int getUserId() {
		return userId;
	}

	public void setUserId(int userId) {
		this.userId = userId;
	}
	
}
