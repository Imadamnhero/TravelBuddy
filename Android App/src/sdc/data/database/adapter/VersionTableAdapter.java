package sdc.data.database.adapter;

import java.util.HashMap;

import sdc.data.database.ContentProviderDB;
import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;

public class VersionTableAdapter extends BaseTableAdapter {

	public static final String TABLE_NAME = ContentProviderDB.PREFIX
			+ "versions";

	public static final String CREATE_TABLE = "CREATE TABLE IF NOT EXISTS "
			+ TABLE_NAME + " (" + ContentProviderDB.COL_USER_ID
			+ " integer primary key, " + ContentProviderDB.COL_VERSION_NOTE
			+ " integer, " + ContentProviderDB.COL_VERSION_EXPENSE
			+ " integer, " + ContentProviderDB.COL_VERSION_CATE + " integer, "
			+ ContentProviderDB.COL_VERSION_PACKING + " integer, "
			+ ContentProviderDB.COL_VERSION_PACKINGITEM + " integer, "
			+ ContentProviderDB.COL_VERSION_PHOTO + " integer, "
			+ ContentProviderDB.COL_VERSION_GROUP + " integer, "
			+ ContentProviderDB.COL_VERSION_PREMADE_PACKING + " integer, "
			+ ContentProviderDB.COL_VERSION_PREMADE_PACKINGITEM + " integer)";

	public VersionTableAdapter(Context context) {
		super(context, TABLE_NAME);
	}

	public HashMap<String, Integer> getVersionTable(int userId) {
		String[] listKey = { ContentProviderDB.COL_VERSION_NOTE,
				ContentProviderDB.COL_VERSION_EXPENSE,
				ContentProviderDB.COL_VERSION_CATE,
				ContentProviderDB.COL_VERSION_PACKING,
				ContentProviderDB.COL_VERSION_PACKINGITEM,
				ContentProviderDB.COL_VERSION_PHOTO,
				ContentProviderDB.COL_VERSION_GROUP,
				ContentProviderDB.COL_VERSION_PREMADE_PACKING,
				ContentProviderDB.COL_VERSION_PREMADE_PACKINGITEM };
		Cursor cursor = super.query(null, ContentProviderDB.COL_USER_ID + "="
				+ userId, null, null);

		// if table haven't trip yet,
		// insert row which have all type version = 0 for that trip
		if (cursor.getCount() == 0) {
			ContentValues values = new ContentValues();
			for (String key : listKey)
				values.put(key, 0);
			values.put(ContentProviderDB.COL_USER_ID, userId);
			super.insert(values);
			cursor = super.query(null, ContentProviderDB.COL_USER_ID + "="
					+ userId, null, null);
		}
		cursor.moveToFirst();
		HashMap<String, Integer> versionTable = new HashMap<String, Integer>();

		for (String key : listKey)
			versionTable.put(key, cursor.getInt(cursor.getColumnIndex(key)));
		return versionTable;
	}

	public int getVersionTableofUser(int userId, String column) {
		Cursor cursor = super.query(new String[] { column },
				ContentProviderDB.COL_USER_ID + "=" + userId, null, null);
		if (cursor.moveToFirst()) {
			return cursor.getInt(cursor.getColumnIndex(column));
		}
		return -1;
	}

	public void setVersionTableOfUser(String column, int ver, int userId) {
		ContentValues values = new ContentValues();
		values.put(column, ver);
		super.update(values, ContentProviderDB.COL_USER_ID + "=" + userId, null);
	}

	public void deleteTripVersions(int userId) {
		super.delete(ContentProviderDB.COL_USER_ID + "=" + userId, null);
	}
}