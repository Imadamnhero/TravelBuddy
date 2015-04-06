package sdc.data.database.adapter;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import com.nostra13.universalimageloader.core.ImageLoader;

import sdc.data.Photo;
import sdc.data.database.ContentProviderDB;
import sdc.net.webservice.BaseWS;
import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.net.Uri;

public class PhotoTableAdapter extends BaseTableAdapter {

	public static final String TABLE_NAME = ContentProviderDB.PREFIX + "photos";

	public static final String CREATE_TABLE = "CREATE TABLE IF NOT EXISTS "
			+ TABLE_NAME + " (" + ContentProviderDB.COL_ID
			+ " integer primary key autoincrement, "
			+ ContentProviderDB.COL_PHOTO_CAPTION + " text, "
			+ ContentProviderDB.COL_PHOTO_URL + " text, "
			+ ContentProviderDB.COL_PHOTO_ISRECEIPT + " integer, "
			+ ContentProviderDB.COL_OWNER + " integer, "
			+ ContentProviderDB.COL_TRIP_ID + " integer, "
			+ ContentProviderDB.COL_SERVER_ID + " integer, "
			+ ContentProviderDB.COL_FLAG + " integer)";

	public PhotoTableAdapter(Context context) {
		super(context, TABLE_NAME);
	}

	public int addPhoto(Photo photo, int tripId, int serverId, int flag) {
		ContentValues values = new ContentValues();
		values.put(ContentProviderDB.COL_PHOTO_CAPTION, photo.getCaption());
		values.put(ContentProviderDB.COL_PHOTO_URL, photo.getUrlImage());
		values.put(ContentProviderDB.COL_PHOTO_ISRECEIPT, photo.isReceipt() ? 1
				: 0);
		values.put(ContentProviderDB.COL_OWNER, photo.getOwnerId());
		values.put(ContentProviderDB.COL_TRIP_ID, tripId);
		values.put(ContentProviderDB.COL_SERVER_ID, serverId);
		values.put(ContentProviderDB.COL_FLAG, flag);
		Uri uri = super.insert(values);
		return Integer.parseInt(uri.getPath().substring(1));
	}

	public void insertOrUpdatePhoto(Photo photo) {
		ContentValues values = new ContentValues();
		values.put(ContentProviderDB.COL_PHOTO_CAPTION, photo.getCaption());
		values.put(ContentProviderDB.COL_PHOTO_URL, photo.getUrlImage());
		values.put(ContentProviderDB.COL_PHOTO_ISRECEIPT, photo.isReceipt() ? 1
				: 0);
		values.put(ContentProviderDB.COL_OWNER, photo.getOwnerId());
		values.put(ContentProviderDB.COL_TRIP_ID, photo.getTripId());
		values.put(ContentProviderDB.COL_SERVER_ID, photo.getServerId());
		values.put(ContentProviderDB.COL_FLAG, ContentProviderDB.FLAG_NONE);
		if (super.update(values,
				ContentProviderDB.COL_SERVER_ID + "=" + photo.getServerId(),
				null) <= 0) {
			super.insert(values);
		}
	}

	public Photo getAPhotoByClientId(int id) {
		Cursor cursor = super.query(null, ContentProviderDB.COL_ID + "=" + id,
				null, null);
		if (cursor.moveToFirst()) {
			int clientId = cursor.getInt(cursor
					.getColumnIndex(ContentProviderDB.COL_ID));
			String caption = cursor.getString(cursor
					.getColumnIndex(ContentProviderDB.COL_PHOTO_CAPTION));
			String url = cursor.getString(cursor
					.getColumnIndex(ContentProviderDB.COL_PHOTO_URL));
			boolean isReceipt = cursor.getInt(cursor
					.getColumnIndex(ContentProviderDB.COL_PHOTO_ISRECEIPT)) == 1 ? true
					: false;
			int ownerId = cursor.getInt(cursor
					.getColumnIndex(ContentProviderDB.COL_OWNER));
			int tripId = cursor.getInt(cursor
					.getColumnIndex(ContentProviderDB.COL_TRIP_ID));
			int serverId = cursor.getInt(cursor
					.getColumnIndex(ContentProviderDB.COL_SERVER_ID));
			int flag = cursor.getInt(cursor
					.getColumnIndex(ContentProviderDB.COL_FLAG));
			return new Photo(clientId, url, caption, ownerId, tripId,
					isReceipt, serverId, flag);
		}
		return null;
	}

	public void updatePhoto(Photo photo, int tripId, int serverId) {
		ContentValues values = new ContentValues();
		values.put(ContentProviderDB.COL_PHOTO_CAPTION, photo.getCaption());
		values.put(ContentProviderDB.COL_PHOTO_URL, photo.getUrlImage());
		values.put(ContentProviderDB.COL_PHOTO_ISRECEIPT, photo.isReceipt() ? 1
				: 0);
		values.put(ContentProviderDB.COL_OWNER, photo.getOwnerId());
		values.put(ContentProviderDB.COL_TRIP_ID, tripId);
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

	public List<Photo> getAllPhotoOfTrip(int tripId) {
		Cursor cursor = super.query(null, ContentProviderDB.COL_TRIP_ID + "="
				+ tripId + " AND " + ContentProviderDB.COL_PHOTO_ISRECEIPT
				+ "=" + 0 + " AND " + ContentProviderDB.COL_FLAG + " <> "
				+ ContentProviderDB.FLAG_DEL, null, null);
		List<Photo> result = new ArrayList<Photo>();
		if (cursor.moveToFirst()) {
			do {
				int id = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_ID));
				String caption = cursor.getString(cursor
						.getColumnIndex(ContentProviderDB.COL_PHOTO_CAPTION));
				String url = cursor.getString(cursor
						.getColumnIndex(ContentProviderDB.COL_PHOTO_URL));
				int isReceipt = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_PHOTO_ISRECEIPT));
				int ownerId = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_OWNER));
				int serverId = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_SERVER_ID));
				int flag = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_FLAG));
				result.add(new Photo(id, url, caption, ownerId, tripId,
						isReceipt == 1 ? true : false, serverId, flag));
			} while (cursor.moveToNext());
		}
		return result;
	}

	public List<Photo> getAll(int tripId) {
		Cursor cursor = super.query(null, ContentProviderDB.COL_TRIP_ID + "="
				+ tripId, null, null);
		List<Photo> result = new ArrayList<Photo>();
		if (cursor.moveToFirst()) {
			do {
				int id = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_ID));
				String caption = cursor.getString(cursor
						.getColumnIndex(ContentProviderDB.COL_PHOTO_CAPTION));
				String url = cursor.getString(cursor
						.getColumnIndex(ContentProviderDB.COL_PHOTO_URL));
				int isReceipt = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_PHOTO_ISRECEIPT));
				int ownerId = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_OWNER));
				int serverId = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_SERVER_ID));
				int flag = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_FLAG));
				result.add(new Photo(id, url, caption, ownerId, tripId,
						isReceipt == 1 ? true : false, serverId, flag));
			} while (cursor.moveToNext());
		}
		return result;
	}

	public List<Photo> getSynchronizedPhotoOfTrip(int tripId) {
		Cursor cursor = super.query(null, ContentProviderDB.COL_TRIP_ID + "="
				+ tripId + " AND " + ContentProviderDB.COL_PHOTO_ISRECEIPT
				+ "=" + 0 + " AND " + ContentProviderDB.COL_FLAG + " <> "
				+ ContentProviderDB.FLAG_DEL + " AND "
				+ ContentProviderDB.COL_SERVER_ID + " <>0", null, null);
		List<Photo> result = new ArrayList<Photo>();
		if (cursor.moveToFirst()) {
			do {
				int id = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_ID));
				String caption = cursor.getString(cursor
						.getColumnIndex(ContentProviderDB.COL_PHOTO_CAPTION));
				String url = cursor.getString(cursor
						.getColumnIndex(ContentProviderDB.COL_PHOTO_URL));
				int isReceipt = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_PHOTO_ISRECEIPT));
				int ownerId = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_OWNER));
				int serverId = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_SERVER_ID));
				int flag = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_FLAG));
				result.add(new Photo(id, url, caption, ownerId, tripId,
						isReceipt == 1 ? true : false, serverId, flag));
			} while (cursor.moveToNext());
		}
		return result;
	}

	public List<Photo> getAllReceiptsOfUser(int userId, int tripId) {
		Cursor cursor = super.query(null, ContentProviderDB.COL_OWNER + " = "
				+ userId + " AND " + ContentProviderDB.COL_PHOTO_ISRECEIPT
				+ " = " + 1 + " AND " + ContentProviderDB.COL_FLAG + " <> "
				+ ContentProviderDB.FLAG_DEL + " AND "
				+ ContentProviderDB.COL_TRIP_ID + " = " + tripId, null, null);
		List<Photo> result = new ArrayList<Photo>();
		if (cursor.moveToFirst()) {
			do {
				int id = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_ID));
				String caption = cursor.getString(cursor
						.getColumnIndex(ContentProviderDB.COL_PHOTO_CAPTION));
				String url = cursor.getString(cursor
						.getColumnIndex(ContentProviderDB.COL_PHOTO_URL));
				int isReceipt = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_PHOTO_ISRECEIPT));
				int ownerId = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_OWNER));
				int serverId = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_SERVER_ID));
				int flag = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_FLAG));
				result.add(new Photo(id, url, caption, ownerId, -1,
						isReceipt == 1 ? true : false, serverId, flag));
			} while (cursor.moveToNext());
		}
		return result;
	}

	public void deleteReceiptOfUser(int userId) {
		this.delete(ContentProviderDB.COL_OWNER + "=" + userId + " AND "
				+ ContentProviderDB.COL_PHOTO_ISRECEIPT + "=" + 1);
	}

	public void deletePhotoOfTrip(int tripId) {
		this.delete(ContentProviderDB.COL_TRIP_ID + "=" + tripId);
	}

	public void doneUpdatingFromServer(Photo photo, int clientId, int serverId,
			String urlImage) {
		Cursor cursor = this.query(new String[] { ContentProviderDB.COL_FLAG,
				ContentProviderDB.COL_PHOTO_URL }, ContentProviderDB.COL_ID
				+ "=" + clientId, null, null);
		if (cursor.moveToFirst()) {
			int flag = cursor.getInt(cursor
					.getColumnIndex(ContentProviderDB.COL_FLAG));
			String localUrl = cursor.getString(cursor
					.getColumnIndex(ContentProviderDB.COL_PHOTO_URL));
			if (photo.getFlag() == ContentProviderDB.FLAG_ADD) {
				ContentValues values = new ContentValues();
				values.put(ContentProviderDB.COL_SERVER_ID, serverId);
				values.put(ContentProviderDB.COL_PHOTO_URL, urlImage);
				if (photo.getFlag() == flag)
					values.put(ContentProviderDB.COL_FLAG,
							ContentProviderDB.FLAG_NONE);
				if (super.update(values, ContentProviderDB.COL_ID + "="
						+ clientId, null) > 0) {
					
					File file = new File(localUrl);
					if(file.exists()){
						try{
					File localCache = ImageLoader.getInstance().getDiscCache()
							.get(BaseWS.HOST + urlImage);
					 ImageLoader.getInstance().clearMemoryCache();
					if (localCache != null && !localCache.exists()
							&& file.exists()) {
						file.renameTo(localCache);
					} //else {
						}catch(Exception e){
							e.printStackTrace();
						}
						file.delete();
					//}
					}
				}
			} else if (photo.getFlag() == ContentProviderDB.FLAG_EDIT) {
				ContentValues edit = new ContentValues();
				if (photo.getFlag() == flag)
					edit.put(ContentProviderDB.COL_FLAG,
							ContentProviderDB.FLAG_NONE);
				super.update(edit, ContentProviderDB.COL_ID + "=" + clientId,
						null);
			} else if (photo.getFlag() == ContentProviderDB.FLAG_DEL) {
				this.delete(ContentProviderDB.COL_ID + "=" + clientId);
			}
		}
	}

	protected int delete(String where) {
		// delete local image before replace url by serverUrl
		Cursor cursor = this.query(new String[] {
				ContentProviderDB.COL_PHOTO_URL,
				ContentProviderDB.COL_SERVER_ID }, where, null, null);
		if (cursor.moveToFirst()) {
			do {
				int serverId = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_SERVER_ID));
				if (serverId == 0) {
					String localUrl = cursor.getString(cursor
							.getColumnIndex(ContentProviderDB.COL_PHOTO_URL));
					File file = new File(localUrl);
					file.delete();
				}
			} while (cursor.moveToNext());
		}
		return super.delete(where, null);
	}

	public int countPhotosOfAUser(int userId, int tripId) {
		Cursor cursor = this.query(new String[] { ContentProviderDB.COL_ID },
				ContentProviderDB.COL_OWNER + " = " + userId + " AND "
						+ ContentProviderDB.COL_PHOTO_ISRECEIPT + " = " + "0"
						+ " AND " + ContentProviderDB.COL_TRIP_ID + "="
						+ tripId, null, null);
		return cursor.getCount();
	}

}
