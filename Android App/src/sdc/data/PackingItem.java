package sdc.data;

public class PackingItem {
	private int id;
	private String item;
	private int listId;
	private boolean isCheck;
	private int serverId;
	private int flag;

	public PackingItem(int id, String item, int listId, boolean isCheck,
			int serverId, int flag) {
		super();
		this.id = id;
		this.item = item;
		this.listId = listId;
		this.isCheck = isCheck;
		this.serverId = serverId;
		this.flag = flag;
	}

	public PackingItem(int id, String item, int listId) {
		super();
		this.id = id;
		this.item = item;
		this.listId = listId;
	}

	public PackingItem(int id, String item, int listId, int serverId) {
		super();
		this.id = id;
		this.item = item;
		this.listId = listId;
		this.serverId = serverId;
	}

	public PackingItem(int id, String item, boolean isCheck) {
		super();
		this.id = id;
		this.item = item;
		this.isCheck = isCheck;
	}

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public String getItem() {
		return item;
	}

	public void setItem(String item) {
		this.item = item;
	}

	public int getListId() {
		return listId;
	}

	public void setListId(int listId) {
		this.listId = listId;
	}

	public boolean isCheck() {
		return isCheck;
	}

	public void setCheck(boolean isCheck) {
		this.isCheck = isCheck;
	}

	public int getServerId() {
		return serverId;
	}

	public void setServerId(int serverId) {
		this.serverId = serverId;
	}

	public int getFlag() {
		return flag;
	}

	public void setFlag(int flag) {
		this.flag = flag;
	}

	public PackingItem clone() {
		return new PackingItem(this.getId(), this.getItem(), this.getListId(),
				this.isCheck(), this.getServerId(), this.getFlag());
	}

}
