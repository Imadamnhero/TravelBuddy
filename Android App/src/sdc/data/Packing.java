package sdc.data;

import java.util.List;

public class Packing {
	private int percent = 0;
	private int id;
	private String title;
	private int ownerId;
	private int serverId;
	private int flag;
	private List<PackingItem> listItem;

	public Packing(int percent, int id, String title, int ownerId,
			int serverId, int flag, List<PackingItem> listItem) {
		super();
		this.percent = percent;
		this.id = id;
		this.title = title;
		this.ownerId = ownerId;
		this.serverId = serverId;
		this.flag = flag;
		this.listItem = listItem;
	}

	public Packing(int id, String title, int ownerId, int serverId, int flag) {
		super();
		this.id = id;
		this.title = title;
		this.ownerId = ownerId;
		this.serverId = serverId;
		this.flag = flag;
	}

	public Packing(int id, String title, int serverId) {
		super();
		this.id = id;
		this.title = title;
		this.serverId = serverId;
	}

	public Packing(int percent, int id, String title, int ownerId,
			List<PackingItem> listItem) {
		super();
		this.percent = percent;
		this.id = id;
		this.title = title;
		this.ownerId = ownerId;
		this.listItem = listItem;
	}

	public void calculatePercent() {
		if (listItem != null) {
			int count = 0;
			for (PackingItem item : listItem) {
				if (item.isCheck())
					count++;
			}
			percent = (int) ((float) count / (float) listItem.size() * 100f);
		}
	}

	public int getPercent() {
		return percent;
	}

	public void setPercent(int percent) {
		this.percent = percent;
	}

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public String getTitle() {
		return title;
	}

	public void setTitle(String type) {
		this.title = type;
	}

	public int getOwnerId() {
		return ownerId;
	}

	public void setOwnerId(int ownerId) {
		this.ownerId = ownerId;
	}

	public List<PackingItem> getListItem() {
		return listItem;
	}

	public void setListItem(List<PackingItem> listItem) {
		this.listItem = listItem;
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

}
