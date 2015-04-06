package sdc.data.database.adapter;

import java.util.ArrayList;
import java.util.List;

import sdc.data.Packing;
import sdc.data.database.ContentProviderDB;
import sdc.ui.fragment.PackingFragment;
import sdc.ui.travelapp.MainActivity;
import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import android.util.Pair;

public class PackingTitleTableAdapter extends BaseTableAdapter {

	public static final String TABLE_NAME = ContentProviderDB.PREFIX
			+ "packing_titles";

	public static final String CREATE_TABLE = "CREATE TABLE IF NOT EXISTS "
			+ TABLE_NAME + " (" + ContentProviderDB.COL_ID
			+ " integer primary key autoincrement, "
			+ ContentProviderDB.COL_PACKING_TITLE + " text, "
			+ ContentProviderDB.COL_OWNER + " integer, "
			+ ContentProviderDB.COL_SERVER_ID + " integer, "
			+ ContentProviderDB.COL_FLAG + " integer)";
	private Context mContext;

	public PackingTitleTableAdapter(Context context) {
		super(context, TABLE_NAME);
		mContext = context;
	}

	public int addPackingTitle(Packing title) {
		ContentValues values = new ContentValues();
		values.put(ContentProviderDB.COL_PACKING_TITLE, title.getTitle());
		values.put(ContentProviderDB.COL_OWNER, title.getOwnerId());
		values.put(ContentProviderDB.COL_SERVER_ID, title.getServerId());
		values.put(ContentProviderDB.COL_FLAG, title.getFlag());
		Uri uri = super.insert(values);
		// this code use to take new id of newly row added
		return Integer.parseInt(uri.getPath().substring(1));
	}

	public List<Packing> getPackingsOfUser(int userId) {
		Cursor cursor = super.query(null, ContentProviderDB.COL_OWNER + "="
				+ userId + " AND " + ContentProviderDB.COL_FLAG + " <> "
				+ ContentProviderDB.FLAG_DEL, null, null);
		if (cursor.moveToFirst()) {
			List<Packing> result = new ArrayList<Packing>();
			do {
				String title = cursor.getString(cursor
						.getColumnIndex(ContentProviderDB.COL_PACKING_TITLE));
				int id = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_ID));
				int ownerId = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_OWNER));
				int serverId = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_SERVER_ID));
				int flag = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_FLAG));
				Packing pack = new Packing(id, title, ownerId, serverId, flag);
				pack.setListItem(new PackingItemTableAdapter(mContext)
						.getItemsOfTitle(pack.getServerId() == 0 ? pack.getId()
								: pack.getServerId()));
				result.add(pack);
			} while (cursor.moveToNext());
			return result;
		}
		return null;
	}

	public void deletePackingOfUser(int userId) {
		List<Packing> listPacking = getPackingsOfUser(userId);
		if (listPacking != null)
			for (Packing packing : listPacking)
				new PackingItemTableAdapter(getContext())
						.deleteItemOfPacking(packing.getId());
		super.delete(ContentProviderDB.COL_OWNER + "=" + userId, null);
	}

	public void deleteOfflinePackingUponId(int id, int serverId) {
		super.deleteOfflineUponId(id);
		if (serverId <= 0) {
			new PackingItemTableAdapter(mContext)
					.deleteOfflineItemOfPacking(id);
		} else {
			new PackingItemTableAdapter(mContext)
					.deleteOfflineItemOfPacking(serverId);
		}
	}

	public List<Packing> getPackingsNeedUpload() {
		Cursor cursor = super.query(null, ContentProviderDB.COL_FLAG + " <> "
				+ ContentProviderDB.FLAG_NONE, null, null);
		if (cursor.moveToFirst()) {
			List<Packing> listPacking = new ArrayList<Packing>();
			do {
				int id = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_ID));
				String title = cursor.getString(cursor
						.getColumnIndex(ContentProviderDB.COL_PACKING_TITLE));
				int ownerId = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_OWNER));
				int serverId = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_SERVER_ID));
				int flag = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_FLAG));
				listPacking
						.add(new Packing(id, title, ownerId, serverId, flag));
			} while (cursor.moveToNext());
			return listPacking;
		}
		return null;
	}

	/**
	 * this function in packing title is specical. So it need to override
	 */
	@Override
	public void doneUpdatingFromServer(List<Pair<Integer, Integer>> updateId) {
		// User serverId in packingTitle to update packingid in packingItem.
		// Sync PackingItem if a packingTitle is uploaded successfully
		boolean needSyncPackingItemTable = false;
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
					// update packing item table
					new PackingItemTableAdapter(mContext).allowARowCanUpload(
							pair.second, pair.first);
					needSyncPackingItemTable = true;
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
		if (needSyncPackingItemTable && mContext instanceof MainActivity)
			PackingFragment.syncPackingItem((MainActivity) mContext);
	}

	public void handleDataFromServer(List<Packing> listPack) {
		for (Packing pack : listPack) {
			if (pack.getFlag() == ContentProviderDB.FLAG_EDIT
					|| pack.getFlag() == ContentProviderDB.FLAG_ADD) {
				insertOrUpdatePack(pack, pack.getServerId());
			} else {
				super.delete(
						ContentProviderDB.COL_SERVER_ID + "="
								+ pack.getServerId(), null);
			}
		}
	}

	/**
	 * If a row from server is exist in table, that row will be updated. If not
	 * exist, it will be inserted
	 * 
	 * @param pack
	 * @param serverId
	 */
	public void insertOrUpdatePack(Packing pack, int serverId) {
		ContentValues values = new ContentValues();
		values.put(ContentProviderDB.COL_PACKING_TITLE, pack.getTitle());
		values.put(ContentProviderDB.COL_OWNER, pack.getOwnerId());
		values.put(ContentProviderDB.COL_SERVER_ID, serverId);
		values.put(ContentProviderDB.COL_FLAG, ContentProviderDB.FLAG_NONE);
		if (super.update(values, ContentProviderDB.COL_SERVER_ID + "="
				+ serverId, null) <= 0) {
			super.insert(values);
		}
	}

}
