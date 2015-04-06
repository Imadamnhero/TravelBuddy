package sdc.data.database.adapter;

import java.util.ArrayList;
import java.util.List;

import sdc.data.User;
import sdc.data.database.ContentProviderDB;
import sdc.net.webservice.GetUserDataWS;
import sdc.ui.travelapp.MainActivity;
import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.util.Pair;

public class UserTableAdapter extends BaseTableAdapter {
	public static final String TABLE_NAME = ContentProviderDB.PREFIX + "users";

	public static final String CREATE_TABLE = "CREATE TABLE IF NOT EXISTS "
			+ TABLE_NAME + " (" + ContentProviderDB.COL_USER_ID
			+ " integer primary key, " + ContentProviderDB.COL_USER_NAME
			+ " text, " + ContentProviderDB.COL_USER_AVATAR + " text)";
	private Context mContext;

	public UserTableAdapter(Context context) {
		super(context, TABLE_NAME);
		mContext = context;
	}

	public void updateTableUser(List<User> listUser) {
		for (User user : listUser)
			this.updateUser(user);
	}

	public void deleteUser(int userId) {
		super.delete(ContentProviderDB.COL_USER_ID + "=" + userId, null);
	}

	public void updateUser(User user) {
		ContentValues values = new ContentValues();
		values.put(ContentProviderDB.COL_USER_ID, user.getId());
		values.put(ContentProviderDB.COL_USER_NAME, user.getName());
		values.put(ContentProviderDB.COL_USER_AVATAR, user.getAvatar());
		if (super.update(values,
				ContentProviderDB.COL_USER_ID + "=" + user.getId(), null) <= 0)
			super.insert(values);
	}

	/**
	 * Get list user from a list of userid, if user info do not exist in table,
	 * call webservice to download that list info
	 * 
	 * @param listId
	 * @return
	 */
	public List<User> getUsersFromUserIds(List<Integer> listId) {
		List<User> result = new ArrayList<User>();
		List<Integer> idDoNotHaveData = new ArrayList<Integer>();
		for (Integer id : listId) {
			Cursor cursor = super.query(null, ContentProviderDB.COL_USER_ID
					+ "=" + id, null, null);
			if (cursor.moveToFirst()) {
				String name = cursor.getString(cursor
						.getColumnIndex(ContentProviderDB.COL_USER_NAME));
				String avatar = cursor.getString(cursor
						.getColumnIndex(ContentProviderDB.COL_USER_AVATAR));
				result.add(new User(id, avatar, name));
			} else {
				result.add(new User(id, "", " ... "));
				idDoNotHaveData.add(id);
			}
		}
		if (idDoNotHaveData.size() > 0 && mContext instanceof MainActivity) {
			new GetUserDataWS((MainActivity) mContext)
					.fetchData(idDoNotHaveData);
		}
		return result;
	}

	public User getUserFromUserId(int userId) {
		Cursor cursor = this.query(null, ContentProviderDB.COL_USER_ID + "="
				+ userId, null, null);
		if (cursor.moveToFirst()) {
			String name = cursor.getString(cursor
					.getColumnIndex(ContentProviderDB.COL_USER_NAME));
			String avatar = cursor.getString(cursor
					.getColumnIndex(ContentProviderDB.COL_USER_AVATAR));
			return new User(userId, avatar, name);
		}
		return new User(userId, "", "...");
	}

	public List<Integer> getAllUserIdInTable() {
		Cursor cursor = this.query(
				new String[] { ContentProviderDB.COL_USER_ID }, null, null,
				null);
		if (cursor.moveToFirst()) {
			List<Integer> listId = new ArrayList<Integer>();
			do {
				listId.add(cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_USER_ID)));
			} while (cursor.moveToNext());
			return listId;
		}
		return null;
	}

	public void deleteListUserInfoOfTrip(int tripId, int mySelfId) {
		List<Pair<Integer, Boolean>> listId = new UsersInGroupTableAdapter(
				mContext).getFriendInATrip(tripId, mySelfId);
		if (listId != null)
			for (Pair<Integer, Boolean> pair : listId)
				super.delete(ContentProviderDB.COL_USER_ID + "=" + pair.first,
						null);
	}
}
