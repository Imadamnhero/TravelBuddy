package sdc.data.database.adapter;

import java.util.ArrayList;
import java.util.List;

import sdc.data.Packing;
import sdc.data.database.ContentProviderDB;
import sdc.net.webservice.GetPremadePackingWS;
import sdc.travelapp.R;
import sdc.ui.travelapp.MainActivity;
import android.content.ContentValues;
import android.database.Cursor;

public class PremadePackingTitleTableAdapter extends BaseTableAdapter {

	public static final String TABLE_NAME = ContentProviderDB.PREFIX
			+ "premade_packing_titles";

	public static final String CREATE_TABLE = "CREATE TABLE IF NOT EXISTS "
			+ TABLE_NAME + " (" + ContentProviderDB.COL_ID
			+ " integer primary key autoincrement, "
			+ ContentProviderDB.COL_PACKING_TITLE + " text, "
			+ ContentProviderDB.COL_SERVER_ID + " integer, "
			+ ContentProviderDB.COL_FLAG + " integer)";

	private MainActivity mContext;

	public PremadePackingTitleTableAdapter(MainActivity context) {
		super(context, TABLE_NAME);
		mContext = context;
	}

	public void addPremadeTitle(String title, int serverId, int flag) {
		ContentValues values = new ContentValues();
		values.put(ContentProviderDB.COL_PACKING_TITLE, title);
		values.put(ContentProviderDB.COL_SERVER_ID, serverId);
		values.put(ContentProviderDB.COL_FLAG, flag);
		if (super.update(values, ContentProviderDB.COL_SERVER_ID + "="
				+ serverId, null) <= 0)
			super.insert(values);
	}

	public void addListPremadeTitle(List<Packing> listTitle) {
		for (Packing packing : listTitle)
			this.addPremadeTitle(packing.getTitle(), packing.getId(),
					ContentProviderDB.FLAG_NONE);
	}

	public void updatePremadeTitle(String title, int serverId) {
		ContentValues values = new ContentValues();
		values.put(ContentProviderDB.COL_PACKING_TITLE, title);
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

	public List<Packing> getPremadePackingTitles() {
		Cursor cursor = super.query(null, null, null, null);
		List<Packing> result = new ArrayList<Packing>();
		if (cursor.moveToFirst()) {
			do {
				String title = cursor.getString(cursor
						.getColumnIndex(ContentProviderDB.COL_PACKING_TITLE));
				int id = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_ID));
				int serverId = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_SERVER_ID));
				result.add(new Packing(id, title, serverId));
			} while (cursor.moveToNext());
		} else {
			new GetPremadePackingWS(mContext).fetchData();
			mContext.showProgressDialog(
					mContext.getString(R.string.title_load_premadepack),
					mContext.getString(R.string.wait_in_sec), null);
			result.add(new Packing(-1, "Loading Premade Packing ...", -1));
		}
		return result;
	}

}