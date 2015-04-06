package sdc.data;

public class Trip {
	private int tripId;
	private int ownerId;
	private int userId;
	private String tripName;
	private String fromDate;
	private String toDate;
	private double budget;
	private int numberOfUserPhotos;
	private int numberOfGroupPhotos;

	public Trip() {
	}

	public Trip(int tripId, int ownerId, int userId, String tripName,
			String fromDate, String toDate, double budget) {
		super();
		this.tripId = tripId;
		this.ownerId = ownerId;
		this.userId = userId;
		this.tripName = tripName;
		this.fromDate = fromDate;
		this.toDate = toDate;
		this.budget = budget;
	}

	public Trip(int tripId, int ownerId, int userId, String tripName,
			String fromDate, String toDate, double budget,
			int numberOfGroupPhotos) {
		super();
		this.tripId = tripId;
		this.ownerId = ownerId;
		this.userId = userId;
		this.tripName = tripName;
		this.fromDate = fromDate;
		this.toDate = toDate;
		this.budget = budget;
		this.numberOfGroupPhotos = numberOfGroupPhotos;
	}

	public int getTripId() {
		return tripId;
	}

	public void setTripId(int tripId) {
		this.tripId = tripId;
	}

	public int getOwnerId() {
		return ownerId;
	}

	public void setOwnerId(int ownerId) {
		this.ownerId = ownerId;
	}

	public String getTripName() {
		return tripName;
	}

	public void setTripName(String tripName) {
		this.tripName = tripName;
	}

	public String getFromDate() {
		return fromDate;
	}

	public void setFromDate(String fromDate) {
		this.fromDate = fromDate;
	}

	public String getToDate() {
		return toDate;
	}

	public void setToDate(String toDate) {
		this.toDate = toDate;
	}

	public int getNumberOfUserPhotos() {
		return numberOfUserPhotos;
	}

	public void setNumberOfUserPhotos(int numberOfUserPhotos) {
		this.numberOfUserPhotos = numberOfUserPhotos;
	}

	public int getNumberOfGroupPhotos() {
		return numberOfGroupPhotos;
	}

	public void setNumberOfGroupPhotos(int numberOfGroupPhotos) {
		this.numberOfGroupPhotos = numberOfGroupPhotos;
	}

	public double getBudget() {
		return budget;
	}

	public void setBudget(double budget) {
		this.budget = budget;
	}

	public int getUserId() {
		return userId;
	}

	public void setUserId(int userId) {
		this.userId = userId;
	}

}
