package sdc.data.database.adapter;

import java.util.ArrayList;
import java.util.List;

import sdc.data.PackingItem;
import sdc.data.database.ContentProviderDB;
import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.util.Pair;

public class PackingItemTableAdapter extends BaseTableAdapter {

	public static final String TABLE_NAME = ContentProviderDB.PREFIX
			+ "packing_items";

	public static final String CREATE_TABLE = "CREATE TABLE IF NOT EXISTS "
			+ TABLE_NAME + " (" + ContentProviderDB.COL_ID
			+ " integer primary key autoincrement, "
			+ ContentProviderDB.COL_PACKING_ITEM + " text, "
			+ ContentProviderDB.COL_PACKING_ISCHECK + " integer, "
			+ ContentProviderDB.COL_PACKING_ID + " integer, "
			+ ContentProviderDB.COL_SERVER_ID + " integer, "
			+ ContentProviderDB.COL_FLAG + " integer, "
			+ ContentProviderDB.COL_ALLOW_UP + " integer)";

	public PackingItemTableAdapter(Context context) {
		super(context, TABLE_NAME);
	}

	public void addPackingItem(PackingItem item, boolean allowUp) {
		ContentValues values = new ContentValues();
		values.put(ContentProviderDB.COL_PACKING_ITEM, item.getItem());
		values.put(ContentProviderDB.COL_PACKING_ISCHECK, item.isCheck() ? 1
				: 0);
		values.put(ContentProviderDB.COL_PACKING_ID, item.getListId());
		values.put(ContentProviderDB.COL_SERVER_ID, item.getServerId());
		values.put(ContentProviderDB.COL_FLAG, item.getFlag());
		values.put(ContentProviderDB.COL_ALLOW_UP, allowUp ? 1 : 0);
		super.insert(values);
	}

	public void addListPackingItem(List<PackingItem> listPacking) {
		for (PackingItem packingItem : listPacking)
			this.addPackingItem(packingItem, false);
	}

	public void updatePackingItem(int packingId, Pair<String, Boolean> item,
			int serverId, boolean allowUp) {
		ContentValues values = new ContentValues();
		values.put(ContentProviderDB.COL_PACKING_ITEM, item.first);
		values.put(ContentProviderDB.COL_PACKING_ISCHECK, item.second ? 1 : 0);
		values.put(ContentProviderDB.COL_PACKING_ID, packingId);
		values.put(ContentProviderDB.COL_SERVER_ID, serverId);
		values.put(ContentProviderDB.COL_FLAG, ContentProviderDB.FLAG_NONE);
		values.put(ContentProviderDB.COL_ALLOW_UP, allowUp ? 1 : 0);
		Cursor cursor = super.query(null, ContentProviderDB.COL_SERVER_ID + "="
				+ serverId, null, null);
		if (cursor.getCount() == 0) {
			super.insert(values);
		} else {
			super.update(values, ContentProviderDB.COL_SERVER_ID + "="
					+ serverId, null);
		}
	}

	public void updateCheckItems(List<PackingItem> listItem) {
		if (listItem != null && listItem.size() > 0) {
			for (PackingItem packingItem : listItem) {
				ContentValues values = new ContentValues();
				values.put(ContentProviderDB.COL_PACKING_ISCHECK,
						packingItem.isCheck() ? 1 : 0);
				values.put(ContentProviderDB.COL_FLAG,
						ContentProviderDB.FLAG_EDIT);
				super.update(values, ContentProviderDB.COL_ID + "="
						+ packingItem.getId(), null);
			}

		}
	}

	public List<PackingItem> getItemsOfTitle(int packingId) {
		Cursor cursor = super.query(null, ContentProviderDB.COL_PACKING_ID
				+ "=" + packingId + " AND " + ContentProviderDB.COL_FLAG + " <> "
						+ ContentProviderDB.FLAG_DEL, null, null);
		if (cursor.moveToFirst()) {
			List<PackingItem> result = new ArrayList<PackingItem>();
			do {
				int id = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_ID));
				int serverId = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_SERVER_ID));
				int flag = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_FLAG));
				String item = cursor.getString(cursor
						.getColumnIndex(ContentProviderDB.COL_PACKING_ITEM));
				Boolean isCheck = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_PACKING_ISCHECK)) == 1 ? true
						: false;
				result.add(new PackingItem(id, item, packingId, isCheck,
						serverId, flag));
			} while (cursor.moveToNext());
			return result;
		}
		return null;
	}

	public void deleteItemOfPacking(int packingId) {
		super.delete(ContentProviderDB.COL_PACKING_ID + "=" + packingId, null);
	}

	public void deleteOfflineItemOfPacking(int packingId) {
		List<PackingItem> listItem = this.getItemsOfTitle(packingId);
		for (PackingItem packingItem : listItem)
			super.deleteOfflineUponId(packingItem.getId());
	}

	public void handleDataFromServer(List<PackingItem> listPack) {
		for (PackingItem pack : listPack) {
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
	public void insertOrUpdatePack(PackingItem pack, int serverId) {
		ContentValues values = new ContentValues();
		values.put(ContentProviderDB.COL_PACKING_ITEM, pack.getItem());
		values.put(ContentProviderDB.COL_PACKING_ISCHECK, pack.isCheck() ? 1
				: 0);
		values.put(ContentProviderDB.COL_PACKING_ID, pack.getListId());
		values.put(ContentProviderDB.COL_SERVER_ID, serverId);
		values.put(ContentProviderDB.COL_FLAG, ContentProviderDB.FLAG_NONE);
		values.put(ContentProviderDB.COL_ALLOW_UP, 1);
		if (super.update(values, ContentProviderDB.COL_SERVER_ID + "="
				+ serverId, null) <= 0) {
			super.insert(values);
		}
	}

	public List<PackingItem> getPackingsNeedUpload() {
		Cursor cursor = super.query(null, ContentProviderDB.COL_FLAG + " <> "
				+ ContentProviderDB.FLAG_NONE, null, null);
		if (cursor.moveToFirst()) {
			List<PackingItem> listPacking = new ArrayList<PackingItem>();
			do {
				if (cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_ALLOW_UP)) == 0 ? true
						: false)
					continue;
				int id = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_ID));
				String item = cursor.getString(cursor
						.getColumnIndex(ContentProviderDB.COL_PACKING_ITEM));
				int isCheck = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_PACKING_ISCHECK));
				int listId = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_PACKING_ID));
				int serverId = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_SERVER_ID));
				int flag = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_FLAG));
				listPacking.add(new PackingItem(id, item, listId,
						isCheck == 1 ? true : false, serverId, flag));
			} while (cursor.moveToNext());
			return listPacking;
		}
		return null;
	}

	/**
	 * Function used to update foreignKey become serverId and allow that row
	 * item can upload to server
	 * 
	 * @param serverPackingId
	 *            id of foreignKey if packingList uploaded
	 * @param clientPackingId
	 *            id of foreignKey if packingList do not upload yet
	 */
	public void allowARowCanUpload(int serverPackingId, int clientPackingId) {
		ContentValues update = new ContentValues();
		update.put(ContentProviderDB.COL_PACKING_ID, serverPackingId);
		update.put(ContentProviderDB.COL_ALLOW_UP, 1);
		super.update(update, ContentProviderDB.COL_PACKING_ID + "="
				+ clientPackingId, null);
	}
}
