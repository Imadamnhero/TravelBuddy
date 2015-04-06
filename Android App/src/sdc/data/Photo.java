package sdc.data;

import java.io.Serializable;

/**
 * Photo class is data which created in addphoto, takephoto and receipt too
 * 
 * @author baolong
 * 
 */
public class Photo implements Serializable{
	/**
	 * 
	 */
	private static final long serialVersionUID = -6778179832470011190L;
	private int id;
	private String urlImage;
	private String caption;
	private int ownerId;
	private int tripId;
	private boolean isReceipt;
	private int serverId;
	private int flag;

	public Photo(int id, String urlImage, String caption, int ownerId,
			int tripId, boolean isReceipt, int serverId, int flag) {
		super();
		this.id = id;
		this.urlImage = urlImage;
		this.caption = caption;
		this.ownerId = ownerId;
		this.tripId = tripId;
		this.isReceipt = isReceipt;
		this.serverId = serverId;
		this.flag = flag;
	}

	public Photo(String urlImage, String caption, int ownerId, boolean isReceipt) {
		super();
		this.urlImage = urlImage;
		this.caption = caption;
		this.ownerId = ownerId;
		this.isReceipt = isReceipt;
	}

	public Photo(int ownerId, int flag) {
		super();
		this.ownerId = ownerId;
		this.flag = flag;
		id = -1;
		urlImage = "";
		caption = "";
		tripId = -1;
		isReceipt = false;
		serverId = -1;
	}
	
	public Photo(int id, int ownerId, int serverId, int flag) {
		super();
		this.id = id;
		this.ownerId = ownerId;
		this.serverId = serverId;
		this.flag = flag;
		urlImage ="";
		caption ="";
		tripId = -1;
		isReceipt = false;
	}

	public String getUrlImage() {
		return urlImage;
	}

	public void setUrlImage(String urlImage) {
		this.urlImage = urlImage;
	}

	public String getCaption() {
		return caption;
	}

	public void setCaption(String caption) {
		this.caption = caption;
	}

	public int getOwnerId() {
		return ownerId;
	}

	public void setOwnerId(int ownerId) {
		this.ownerId = ownerId;
	}

	public boolean isReceipt() {
		return isReceipt;
	}

	public void setReceipt(boolean isReceipt) {
		this.isReceipt = isReceipt;
	}

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public int getTripId() {
		return tripId;
	}

	public void setTripId(int tripId) {
		this.tripId = tripId;
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
