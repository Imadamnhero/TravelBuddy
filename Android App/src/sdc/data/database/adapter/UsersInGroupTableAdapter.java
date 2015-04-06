package sdc.data.database.adapter;

import java.util.ArrayList;
import java.util.List;

import sdc.data.database.ContentProviderDB;
import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.util.Pair;

public class UsersInGroupTableAdapter extends BaseTableAdapter {

	public static final String TABLE_NAME = ContentProviderDB.PREFIX + "groups";

	public static final String CREATE_TABLE = "CREATE TABLE IF NOT EXISTS "
			+ TABLE_NAME + " (" + ContentProviderDB.COL_ID
			+ " integer primary key autoincrement, "
			+ ContentProviderDB.COL_TRIP_ID + " integer, "
			+ ContentProviderDB.COL_SERVER_ID + " integer, "
			+ ContentProviderDB.COL_USER_ID + " integer, "
			+ ContentProviderDB.COL_FLAG + " integer, "
			+ ContentProviderDB.COL_GROUP_PENDING + " integer)";

	public UsersInGroupTableAdapter(Context context) {
		super(context, TABLE_NAME);
	}

	/**
	 * When a user added on serverDB successful, it will add to clientDB, So it
	 * must have param serverId
	 * 
	 * @param userId
	 * @param tripId
	 * @param serverId
	 */
	public void addUserToGroup(int userId, int tripId, int serverId, int flag) {
		ContentValues values = new ContentValues();
		values.put(ContentProviderDB.COL_TRIP_ID, tripId);
		values.put(ContentProviderDB.COL_USER_ID, userId);
		values.put(ContentProviderDB.COL_SERVER_ID, serverId);
		values.put(ContentProviderDB.COL_FLAG, flag);
		super.insert(values);
	}

	public void updateUser(int userId, int tripId, int serverId) {
		ContentValues values = new ContentValues();
		values.put(ContentProviderDB.COL_TRIP_ID, tripId);
		values.put(ContentProviderDB.COL_USER_ID, userId);
		values.put(ContentProviderDB.COL_SERVER_ID, serverId);
		values.put(ContentProviderDB.COL_FLAG, ContentProviderDB.FLAG_NONE);
		Cursor cursor = super.query(null, ContentProviderDB.COL_SERVER_ID + "="
				+ serverId, null, null);
		if (cursor.getCount() == 0)
			super.insert(values);
		else
			super.update(values, ContentProviderDB.COL_SERVER_ID + "="
					+ serverId, null);
	}

	public void deleteUsersInTrip(int tripId) {
		super.delete(ContentProviderDB.COL_TRIP_ID + "=" + tripId, null);
	}

	public void deleteUsersInTrip(int tripId, int userId) {
		super.delete(ContentProviderDB.COL_TRIP_ID + "=" + tripId + " AND "
				+ ContentProviderDB.COL_USER_ID + "=" + userId, null);
	}

	public void addUserToGroup(int userId, int tripId, int pendingStt) {
		if (pendingStt == 3) {
			super.delete(ContentProviderDB.COL_USER_ID + "=" + userId, null);
		} else {
			ContentValues values = new ContentValues();
			values.put(ContentProviderDB.COL_TRIP_ID, tripId);
			values.put(ContentProviderDB.COL_USER_ID, userId);
			values.put(ContentProviderDB.COL_GROUP_PENDING, pendingStt);
			if (super.update(values, ContentProviderDB.COL_USER_ID + "="
					+ userId, null) < 1)
				super.insert(values);
		}
	}

	/**
	 * Get User In Group Without User is using app
	 * 
	 * @param tripId
	 *            id of trip equivalent with group
	 * @param mySelfId
	 *            id of user is using app
	 * @return List users who is same group with userid
	 */
	public List<Pair<Integer, Boolean>> getFriendInATrip(int tripId,
			int mySelfId) {
		Cursor cursor = super.query(null, ContentProviderDB.COL_TRIP_ID + "="
				+ tripId + " AND " + ContentProviderDB.COL_USER_ID + " <> "
				+ mySelfId + " AND " + ContentProviderDB.COL_GROUP_PENDING
				+ "=" + 0, null, null);
		if (cursor.moveToFirst()) {
			List<Pair<Integer, Boolean>> list = new ArrayList<Pair<Integer, Boolean>>();
			do {
				int id = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_USER_ID));
				int isPending = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_GROUP_PENDING));
				list.add(new Pair<Integer, Boolean>(id, isPending == 1 ? true
						: false));
			} while (cursor.moveToNext());
			return list;
		}
		return null;
	}

	/**
	 * Get User In Group Without User is using app who don't have pending stt =
	 * 1 (User isn't pending user)
	 * 
	 * @param tripId
	 *            id of trip equivalent with group
	 * @param myself
	 *            id of user is using app
	 * @return List users who is same grourp with userid
	 */
	public List<Integer> getFriendNotPending(int tripId, int myself) {
		Cursor cursor = super.query(null,
				ContentProviderDB.COL_TRIP_ID + "=" + tripId + " AND "
						+ ContentProviderDB.COL_GROUP_PENDING + "=" + 0
						+ " AND " + ContentProviderDB.COL_USER_ID + " <> "
						+ myself, null, null);
		if (cursor.moveToFirst()) {
			List<Integer> list = new ArrayList<Integer>();
			do {
				list.add(cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_USER_ID)));
			} while (cursor.moveToNext());
			return list;
		}
		return null;
	}

	public void deleteTripOfUser(int tripId) {
		super.delete(ContentProviderDB.COL_TRIP_ID + "=" + tripId, null);
	}

}
