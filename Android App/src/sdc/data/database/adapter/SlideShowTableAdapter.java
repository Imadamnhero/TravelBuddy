package sdc.data.database.adapter;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import sdc.data.SlideShow;
import sdc.data.database.ContentProviderDB;
import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;

public class SlideShowTableAdapter extends BaseTableAdapter {

	public static final String TAG = "travel_database";
	public static final String TABLE_NAME = ContentProviderDB.PREFIX
			+ "slideshows";

	public static final String CREATE_TABLE = "CREATE TABLE IF NOT EXISTS "
			+ TABLE_NAME + " (" + ContentProviderDB.COL_ID
			+ " integer primary key autoincrement, "
			+ ContentProviderDB.COL_FILE_PATH + " text, "
			+ ContentProviderDB.COL_SERVER_PATH + " text, "
			+ ContentProviderDB.COL_THUMB + " text,"
			+ ContentProviderDB.COL_TRIP_ID + " integer, "
			+ ContentProviderDB.COL_USER_ID + " integer )";

	public SlideShowTableAdapter(Context context) {
		super(context, TABLE_NAME);
	}

	public void add(String filePath, String serverPath, String thumbnail,
			int tripId, int userId) {
		ContentValues values = new ContentValues();
		values.put(ContentProviderDB.COL_FILE_PATH, filePath);
		values.put(ContentProviderDB.COL_SERVER_PATH, serverPath);
		values.put(ContentProviderDB.COL_THUMB, thumbnail);
		values.put(ContentProviderDB.COL_TRIP_ID, tripId);
		values.put(ContentProviderDB.COL_USER_ID, userId);
		super.insert(values);
	}

	public void deleteSlideShow(int id) {
		Cursor cursor = super.query(null, ContentProviderDB.COL_ID + "=" + id, null, null);
		if (cursor.moveToNext()) {
			File file = new File(cursor.getString(cursor
					.getColumnIndex(ContentProviderDB.COL_FILE_PATH)));
			if(file.exists()){
				file.delete();
			}
		}
		super.delete(ContentProviderDB.COL_ID + "=" + id, null);
	}

	public List<SlideShow> getAll(int tripId, int userId) {
		Cursor cursor = super.query(null, ContentProviderDB.COL_TRIP_ID + "="
				+ tripId + " AND " + ContentProviderDB.COL_USER_ID + "="
				+ userId, null, null);
		List<SlideShow> result = new ArrayList<SlideShow>();
		while (cursor.moveToNext()) {
			SlideShow item = new SlideShow();
			item.setFilePath(cursor.getString(cursor
					.getColumnIndex(ContentProviderDB.COL_FILE_PATH)));
			item.setServerPath(cursor.getString(cursor
					.getColumnIndex(ContentProviderDB.COL_SERVER_PATH)));
			item.setThumbnail((cursor.getString(cursor
					.getColumnIndex(ContentProviderDB.COL_THUMB))));
			item.setId(cursor.getInt(cursor.getColumnIndex(ContentProviderDB.COL_ID)));
			if(new File(item.getFilePath()).exists()){
				result.add(item);
			}else{
				deleteSlideShow(item.getId());
			}
		}
		return result;
	}
}
