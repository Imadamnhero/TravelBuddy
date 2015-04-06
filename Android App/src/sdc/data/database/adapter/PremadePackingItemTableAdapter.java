package sdc.data.database.adapter;

import java.util.ArrayList;
import java.util.List;

import sdc.data.PackingItem;
import sdc.data.database.ContentProviderDB;
import sdc.net.webservice.GetPremadeItemWS;
import sdc.travelapp.R;
import sdc.ui.travelapp.MainActivity;
import android.content.ContentValues;
import android.database.Cursor;

public class PremadePackingItemTableAdapter extends BaseTableAdapter {

	public static final String TABLE_NAME = ContentProviderDB.PREFIX
			+ "premade_packing_items";

	public static final String CREATE_TABLE = "CREATE TABLE IF NOT EXISTS "
			+ TABLE_NAME + " (" + ContentProviderDB.COL_ID
			+ " integer primary key autoincrement, "
			+ ContentProviderDB.COL_PACKING_ITEM + " text, "
			+ ContentProviderDB.COL_PACKING_ID + " integer, "
			+ ContentProviderDB.COL_SERVER_ID + " integer, "
			+ ContentProviderDB.COL_FLAG + " integer)";

	private MainActivity mContext;

	public PremadePackingItemTableAdapter(MainActivity context) {
		super(context, TABLE_NAME);
		mContext = context;
	}

	public void addPremadeItem(int packingId, String item, int serverId,
			int flag) {
		ContentValues values = new ContentValues();
		values.put(ContentProviderDB.COL_PACKING_ITEM, item);
		values.put(ContentProviderDB.COL_PACKING_ID, packingId);
		values.put(ContentProviderDB.COL_SERVER_ID, serverId);
		values.put(ContentProviderDB.COL_FLAG, flag);
		super.insert(values);
	}

	public void addListPremadeItem(List<PackingItem> listItem) {
		for (PackingItem packingItem : listItem)
			this.updatePremadeItem(packingItem.getListId(),
					packingItem.getItem(), packingItem.getServerId());
	}

	public void updatePremadeItem(int packingId, String item, int serverId) {
		ContentValues values = new ContentValues();
		values.put(ContentProviderDB.COL_PACKING_ITEM, item);
		values.put(ContentProviderDB.COL_PACKING_ID, packingId);
		values.put(ContentProviderDB.COL_SERVER_ID, serverId);
		values.put(ContentProviderDB.COL_FLAG, ContentProviderDB.FLAG_NONE);
		Cursor cursor = super.query(null, ContentProviderDB.COL_SERVER_ID + "="
				+ serverId, null, null);
		if (cursor.getCount() == 0) {
			super.insert(values);
		} else {
			super.update(values, ContentProviderDB.COL_SERVER_ID + "="
					+ serverId, null);
		}
	}

	public List<PackingItem> getPremadeItemsOfTitle(int packingId) {
		Cursor cursor = super.query(null, ContentProviderDB.COL_PACKING_ID
				+ "=" + packingId, null, null);
		List<PackingItem> result = new ArrayList<PackingItem>();
		if (cursor.moveToFirst()) {
			do {
				int id = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_ID));
				String item = cursor.getString(cursor
						.getColumnIndex(ContentProviderDB.COL_PACKING_ITEM));
				result.add(new PackingItem(id, item, false));
			} while (cursor.moveToNext());
		} else {
			new GetPremadeItemWS(mContext).fetchData();
			mContext.showProgressDialog(
					mContext.getString(R.string.title_load_premadepack),
					mContext.getString(R.string.wait_in_sec), null);
			result.add(new PackingItem(-1, "Loading Premade Item ...", false));
		}
		return result;
	}

}
