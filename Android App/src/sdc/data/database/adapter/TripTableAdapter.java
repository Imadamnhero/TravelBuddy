package sdc.data.database.adapter;

import sdc.data.Trip;
import sdc.data.database.ContentProviderDB;
import sdc.net.webservice.GetTripWS;
import sdc.ui.travelapp.MainActivity;
import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.util.Log;

public class TripTableAdapter extends BaseTableAdapter {

	public static final String TAG = "travel_database";
	public static final String TABLE_NAME = ContentProviderDB.PREFIX + "trips";

	public static final String CREATE_TABLE = "CREATE TABLE IF NOT EXISTS "
			+ TABLE_NAME + " (" + ContentProviderDB.COL_ID
			+ " integer primary key autoincrement, "
			+ ContentProviderDB.COL_TRIP_NAME + " text, "
			+ ContentProviderDB.COL_TRIP_STARTDATE + " text, "
			+ ContentProviderDB.COL_TRIP_FINISHDATE + " text, "
			+ ContentProviderDB.COL_OWNER + " integer, "
			+ ContentProviderDB.COL_TRIP_ID + " integer, "
			+ ContentProviderDB.COL_USER_ID + " integer, "
			+ ContentProviderDB.COL_TRIP_BUDGET + " real)";
	private Context mListener;

	public TripTableAdapter(Context context) {
		super(context, TABLE_NAME);
		mListener = context;
	}

	public void updateTrip(Trip trip) {
		ContentValues values = new ContentValues();
		values.put(ContentProviderDB.COL_TRIP_NAME, trip.getTripName());
		values.put(ContentProviderDB.COL_TRIP_STARTDATE, trip.getFromDate());
		values.put(ContentProviderDB.COL_TRIP_FINISHDATE, trip.getToDate());
		values.put(ContentProviderDB.COL_OWNER, trip.getOwnerId());
		values.put(ContentProviderDB.COL_TRIP_ID, trip.getTripId());
		values.put(ContentProviderDB.COL_USER_ID, trip.getUserId());
		values.put(ContentProviderDB.COL_TRIP_BUDGET, trip.getBudget());
		if (super.update(values,
				ContentProviderDB.COL_TRIP_ID + "=" + trip.getTripId(), null) <= 0) {
			super.insert(values);
		}
	}

	public void deleteTrip(int tripId) {
		super.delete(ContentProviderDB.COL_TRIP_ID + "=" + tripId, null);
	}

	public Trip getTrip(int tripId, int userId) {
		if (tripId <= 0 || userId <= 0)
			return new Trip(tripId, -1, userId, "Loading ...", "0/0/0000",
					"0/0/0000", 0);
		Cursor cursor = super.query(null, ContentProviderDB.COL_TRIP_ID + "="
				+ tripId + " AND " + ContentProviderDB.COL_USER_ID + "="
				+ userId, null, null);
		if (cursor.moveToFirst()) {
			String location = cursor.getString(cursor
					.getColumnIndex(ContentProviderDB.COL_TRIP_NAME));
			String startdate = cursor.getString(cursor
					.getColumnIndex(ContentProviderDB.COL_TRIP_STARTDATE));
			String finishdate = cursor.getString(cursor
					.getColumnIndex(ContentProviderDB.COL_TRIP_FINISHDATE));
			int ownerId = cursor.getInt(cursor
					.getColumnIndex(ContentProviderDB.COL_OWNER));
			double budget = cursor.getDouble(cursor
					.getColumnIndex(ContentProviderDB.COL_TRIP_BUDGET));
			return new Trip(tripId, ownerId, userId, location, startdate,
					finishdate, budget);
		} else {
			// if Trip data isn't exist, we get it from webservice
			if (mListener instanceof MainActivity)
				new GetTripWS((MainActivity) mListener).fetchData(tripId,
						userId);
			else
				Log.i(TAG, "Wrong listener, so we can't run getTripWS");
			return new Trip(tripId, -1, userId, "Loading ...", "0/0/0000",
					"0/0/0000", 0);
		}
	}

	public void deleteTrip(int tripId, int userId) {
		super.delete(ContentProviderDB.COL_TRIP_ID + "=" + tripId + " AND "
				+ ContentProviderDB.COL_USER_ID + "=" + userId, null);
	}

	public void setTripBudget(int tripId, double budget) {
		ContentValues values = new ContentValues();
		values.put(ContentProviderDB.COL_TRIP_BUDGET, budget);
		super.update(values, ContentProviderDB.COL_TRIP_ID + "=" + tripId, null);
	}

	public void updateTripName(String newName, int userId) {
		ContentValues values = new ContentValues();
		values.put(ContentProviderDB.COL_TRIP_NAME, newName);
		super.update(values, ContentProviderDB.COL_USER_ID + "=" + userId, null);
	}

}
