package sdc.data.database.adapter;

import java.util.List;

import sdc.data.database.ContentProviderDB;
import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import android.util.Pair;

public class BaseTableAdapter {
	private Context mContext;
	private Uri mContentUri;

	public BaseTableAdapter(Context context, String tableName) {
		mContext = context;
		mContentUri = Uri.withAppendedPath(ContentProviderDB.CONTENT_URI,
				tableName);
	}

	protected Uri insert(ContentValues values) {
		return mContext.getContentResolver().insert(mContentUri, values);
	}

	protected int update(ContentValues values, String where,
			String[] selectionArgs) {
		return mContext.getContentResolver().update(mContentUri, values, where,
				selectionArgs);
	}

	protected int delete(String where, String[] selectionArgs) {
		return mContext.getContentResolver().delete(mContentUri, where,
				selectionArgs);
	}

	protected Cursor query(String[] projection, String selection,
			String[] selectionArgs, String sortOrder) {
		return mContext.getContentResolver().query(mContentUri, projection,
				selection, selectionArgs, sortOrder);
	}
	
	public void clearTable() {
		delete(null, null);
		
	}

	/**
	 * upload new data to server successfully, if = add: change flag none and
	 * serverId = id on server, if flag = edit: change flag none, if flag = del:
	 * delete that row
	 * 
	 * @param id
	 *            Id of row modified
	 * @param serverId
	 *            serverId row modified
	 */
	public void doneUpdatingFromServer(List<Pair<Integer, Integer>> updateId) {
		for (Pair<Integer, Integer> pair : updateId) {
			Cursor cursor = this.query(
					new String[] { ContentProviderDB.COL_FLAG },
					ContentProviderDB.COL_ID + "=" + pair.first, null, null);
			if (cursor.moveToFirst()) {
				int flag = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_FLAG));
				if (flag == ContentProviderDB.FLAG_ADD) {
					ContentValues add = new ContentValues();
					add.put(ContentProviderDB.COL_SERVER_ID, pair.second);
					add.put(ContentProviderDB.COL_FLAG,
							ContentProviderDB.FLAG_NONE);
					this.update(add, ContentProviderDB.COL_ID + "="
							+ pair.first, null);
				} else if (flag == ContentProviderDB.FLAG_EDIT) {
					ContentValues edit = new ContentValues();
					edit.put(ContentProviderDB.COL_FLAG,
							ContentProviderDB.FLAG_NONE);
					this.update(edit, ContentProviderDB.COL_ID + "="
							+ pair.first, null);
				} else if (flag == ContentProviderDB.FLAG_DEL) {
					this.delete(ContentProviderDB.COL_ID + "=" + pair.first,
							null);
				}
			}
		}
	}

	public void deleteUponId(int id) {
		this.delete(ContentProviderDB.COL_ID + "=" + id, null);
	}

	public void deleteUponServerId(int id) {
		this.delete(ContentProviderDB.COL_SERVER_ID + "=" + id, null);
	}

	public void deleteOfflineUponId(int id) {
		ContentValues values = new ContentValues();
		values.put(ContentProviderDB.COL_FLAG, ContentProviderDB.FLAG_DEL);
		this.update(values, ContentProviderDB.COL_ID + "=" + id, null);
	}

	public Context getContext() {
		return mContext;
	}

	public boolean checkNeedSync() {
		Cursor cursor = this.query(null, ContentProviderDB.COL_FLAG + " <> "
				+ 0, null, null);
		if (cursor != null)
			return cursor.getCount() > 0 ? true : false;
		else
			return false;
	}

}
