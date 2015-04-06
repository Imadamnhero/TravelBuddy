package sdc.data.database.adapter;

import java.util.ArrayList;
import java.util.List;

import sdc.data.Category;
import sdc.data.Expense;
import sdc.data.database.ContentProviderDB;
import sdc.ui.fragment.ExpensesFragment;
import sdc.ui.travelapp.MainActivity;
import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.net.Uri;

public class CategoryTableAdapter extends BaseTableAdapter {

	public static final String TABLE_NAME = ContentProviderDB.PREFIX
			+ "categories";

	public static final String CREATE_TABLE = "CREATE TABLE IF NOT EXISTS "
			+ TABLE_NAME + " (" + ContentProviderDB.COL_ID
			+ " integer primary key autoincrement, "
			+ ContentProviderDB.COL_CATE_NAMECATE + " text, "
			+ ContentProviderDB.COL_COLOR + " integer, "
			+ ContentProviderDB.COL_SERVER_ID + " integer, "
			+ ContentProviderDB.COL_USER_ID + " integer, "
			+ ContentProviderDB.COL_FLAG + " integer)";
	private Context mContext;

	public CategoryTableAdapter(Context context) {
		super(context, TABLE_NAME);
		mContext = context;
	}

	/*
	 * public int addCategory(String category, int serverId, int flag) {
	 * ContentValues values = new ContentValues();
	 * values.put(ContentProviderDB.COL_CATE_NAMECATE, category);
	 * values.put(ContentProviderDB.COL_SERVER_ID, serverId);
	 * values.put(ContentProviderDB.COL_FLAG, flag); Uri uri =
	 * super.insert(values); return Integer.parseInt(uri.getLastPathSegment());
	 * }
	 */
	public int updateCategory(String category, int serverId, int color,
			int userId) {
		ContentValues values = new ContentValues();
		values.put(ContentProviderDB.COL_CATE_NAMECATE, category);
		values.put(ContentProviderDB.COL_SERVER_ID, serverId);
		values.put(ContentProviderDB.COL_COLOR, color);
		values.put(ContentProviderDB.COL_USER_ID, userId);
		values.put(ContentProviderDB.COL_FLAG, ContentProviderDB.FLAG_NONE);
		Cursor cursor = super.query(null, ContentProviderDB.COL_SERVER_ID + "="
				+ serverId, null, null);
		if (cursor.getCount() == 0) {
			Uri uri = super.insert(values);
			cursor.close();
			return Integer.parseInt(uri.getLastPathSegment());
		} else {
			super.update(values, ContentProviderDB.COL_SERVER_ID + "="
					+ serverId, null);
			cursor.moveToFirst();
			int id = cursor.getInt(cursor
					.getColumnIndex(ContentProviderDB.COL_ID));
			return id;
		}
	}

	public void updateTitle(int id, String title) {
		ContentValues values = new ContentValues();
		values.put(ContentProviderDB.COL_CATE_NAMECATE, title);
		values.put(ContentProviderDB.COL_FLAG, ContentProviderDB.FLAG_EDIT);
		super.update(values, ContentProviderDB.COL_ID + "=" + id, null);
	}

	public int addOrUpdateCategory(Category category, int color, int userId) {
		ContentValues values = new ContentValues();
		values.put(ContentProviderDB.COL_CATE_NAMECATE, category.getNameCate());
		values.put(ContentProviderDB.COL_SERVER_ID, category.getId());
		values.put(ContentProviderDB.COL_COLOR, color);
		values.put(ContentProviderDB.COL_USER_ID, userId);

		if (category.getId() > 0) {
			Cursor cursor = super.query(null, ContentProviderDB.COL_SERVER_ID
					+ "=" + category.getId(), null, null);
			if (cursor.getCount() == 0) {
				values.put(ContentProviderDB.COL_FLAG,
						ContentProviderDB.FLAG_ADD);
				Uri uri = super.insert(values);
				cursor.close();
				return Integer.parseInt(uri.getLastPathSegment());
			} else {
				values.put(ContentProviderDB.COL_FLAG,
						ContentProviderDB.FLAG_EDIT);
				super.update(values, ContentProviderDB.COL_SERVER_ID + "="
						+ category.getId(), null);
				cursor.moveToFirst();
				int id = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_ID));
				cursor.close();
				return id;
			}
		} else if (category.getLocalId() > 0) {
			Cursor cursor = super.query(null, ContentProviderDB.COL_ID

			+ "=" + category.getLocalId(), null, null);
			if (cursor.getCount() == 0) {
				values.put(ContentProviderDB.COL_FLAG,
						ContentProviderDB.FLAG_ADD);
				Uri uri = super.insert(values);
				cursor.close();
				return Integer.parseInt(uri.getLastPathSegment());
			} else {
				values.put(ContentProviderDB.COL_FLAG,
						ContentProviderDB.FLAG_EDIT);
				super.update(values,
						ContentProviderDB.COL_ID + "=" + category.getLocalId(),
						null);
				cursor.moveToFirst();
				int id = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_ID));
				cursor.close();
				return id;
			}
		} else {
			values.put(ContentProviderDB.COL_FLAG, ContentProviderDB.FLAG_ADD);
			Uri uri = super.insert(values);
			return Integer.parseInt(uri.getLastPathSegment());
		}
	}

	public int getLocalCatId(int serverId) {
		Cursor cursor = super.query(new String[] { ContentProviderDB.COL_ID },
				ContentProviderDB.COL_SERVER_ID + "=" + serverId, null, null);
		if (cursor.moveToFirst()) {
			return cursor.getInt(0);
		} else {
			return 0;
		}
	}

	public ArrayList<Category> getAllCategory(int userId) {
		Cursor cursor = super.query(null, ContentProviderDB.COL_USER_ID + "="
				+ userId + " OR " + ContentProviderDB.COL_USER_ID + "=0", null,
				null);
		if (cursor.moveToFirst()) {
			ArrayList<Category> result = new ArrayList<Category>();
			do {
				String nameCate = cursor.getString(cursor
						.getColumnIndex(ContentProviderDB.COL_CATE_NAMECATE));
				int id = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_SERVER_ID));
				Category category = new Category(id, nameCate);
				category.setLocalId(cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_ID)));
				category.setFlag(cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_FLAG)));
				category.setColor(cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_COLOR)));
				category.setUserId(cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_USER_ID)));
				result.add(category);
			} while (cursor.moveToNext());
			return result;
		}
		return null;
	}

	public ArrayList<Integer> getAllColor(int userId) {
		ArrayList<Integer> result = new ArrayList<Integer>();
		Cursor cursor = super.query(
				new String[] { ContentProviderDB.COL_COLOR },
				ContentProviderDB.COL_USER_ID + "=" + userId + " OR "
						+ ContentProviderDB.COL_USER_ID + "=0", null, null);
		while (cursor.moveToNext()) {
			result.add(cursor.getInt(0));
		}
		return result;
	}

	/**
	 * Get list category from a list of cateid, if category do not exist in
	 * table, call webservice to download that category info
	 * 
	 * @param listId
	 * @return
	 */
	public List<Category> getCategoriesFromCateIds(List<Integer> listId) {
		List<Category> result = new ArrayList<Category>();
		List<Integer> idDoNotHaveData = new ArrayList<Integer>();
		for (Integer id : listId) {
			Cursor cursor = super.query(null, ContentProviderDB.COL_SERVER_ID
					+ "=" + id, null, null);
			if (cursor.moveToFirst()) {
				String nameCate = cursor.getString(cursor
						.getColumnIndex(ContentProviderDB.COL_CATE_NAMECATE));
				Category category = new Category(id, nameCate);
				category.setLocalId(cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_ID)));
				category.setFlag(cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_FLAG)));
				category.setColor(cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_COLOR)));
				result.add(category);
			} else {
				result.add(new Category(id, "Loading ..."));
				idDoNotHaveData.add(id);
			}
		}
		if ((idDoNotHaveData.size() > 0 && mContext instanceof MainActivity)
				|| listId.size() == 0) {
			ExpensesFragment.syncExpenseCategories((MainActivity) mContext);
		}
		return result;
	}

	public List<Category> getCategoriesFromLocalCateIds(List<Integer> listId) {
		List<Category> result = new ArrayList<Category>();
		List<Integer> idDoNotHaveData = new ArrayList<Integer>();
		for (Integer id : listId) {
			Cursor cursor = super.query(null, ContentProviderDB.COL_ID + "="
					+ id, null, null);
			if (cursor.moveToFirst()) {
				String nameCate = cursor.getString(cursor
						.getColumnIndex(ContentProviderDB.COL_CATE_NAMECATE));
				Category category = new Category(id, nameCate);
				category.setLocalId(cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_ID)));
				category.setFlag(cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_FLAG)));
				category.setColor(cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_COLOR)));
				result.add(category);
			} else {
				result.add(new Category(id, "Loading ..."));
				idDoNotHaveData.add(id);
			}
		}
		if ((idDoNotHaveData.size() > 0 && mContext instanceof MainActivity)
				|| listId.size() == 0) {
			ExpensesFragment.syncExpenseCategories((MainActivity) mContext);
		}
		return result;
	}

	public List<Category> getCategoriesNeedUpload() {
		Cursor cursor = super.query(null, ContentProviderDB.COL_FLAG + " <> "
				+ ContentProviderDB.FLAG_NONE, null, null);
		List<Category> result = new ArrayList<Category>();
		if (cursor.moveToFirst()) {

			do {
				String nameCate = cursor.getString(cursor
						.getColumnIndex(ContentProviderDB.COL_CATE_NAMECATE));
				int id = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_SERVER_ID));
				Category category = new Category(id, nameCate);
				category.setLocalId(cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_ID)));
				category.setFlag(cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_FLAG)));
				category.setColor(cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_COLOR)));
				category.setUserId(cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_USER_ID)));
				result.add(category);
			} while (cursor.moveToNext());
		}
		return result;
	}

	public int getNextColor(int userId) {
		List<Integer> colors = getAllColor(userId);
		int color = Expense.getNextColor(colors);
		return color;
	}

	public void handleDataFromServer(List<Category> items, int userId) {
		List<Integer> colors = getAllColor(userId);
		for (Category category : items) {
			if (category.getFlag() == ContentProviderDB.FLAG_DEL) {
				super.delete(
						ContentProviderDB.COL_SERVER_ID + "="
								+ category.getId(), null);
				new ExpenseTableAdapter(mContext)
						.deleteExpenseOfServerCategory(category.getId());
			} else {
				ContentValues values = new ContentValues();
				values.put(ContentProviderDB.COL_CATE_NAMECATE,
						category.getNameCate());
				values.put(ContentProviderDB.COL_SERVER_ID, category.getId());
				values.put(ContentProviderDB.COL_USER_ID, category.getUserId());
				values.put(ContentProviderDB.COL_FLAG,
						ContentProviderDB.FLAG_NONE);
				Cursor cursor = super.query(
						null,
						ContentProviderDB.COL_SERVER_ID + "="
								+ category.getId(), null, null);
				if (cursor.getCount() == 0) {
					int color = Expense.getNextColor(colors);
					colors.add(color);
					values.put(ContentProviderDB.COL_COLOR, color);
					category.setColor(color);
					Uri uri = super.insert(values);
					cursor.close();
					category.setId(Integer.parseInt(uri.getLastPathSegment()));
				} else {
					super.update(values, ContentProviderDB.COL_SERVER_ID + "="
							+ category.getId(), null);
					cursor.moveToFirst();
					int id = cursor.getInt(cursor
							.getColumnIndex(ContentProviderDB.COL_ID));
					category.setLocalId(id);
					category.setColor(cursor
							.getColumnIndex(ContentProviderDB.COL_COLOR));
				}
			}
		}
	}

	public boolean isNameExist(String nameOfCategory, int localCatId) {
		String where = ContentProviderDB.COL_CATE_NAMECATE + " LIKE \'"
				+ nameOfCategory.toLowerCase() + "\' ";
		if (localCatId != 0) {
			where += ContentProviderDB.COL_CATE_ID + "=" + localCatId;
		}
		Cursor cursor = super.query(null, where, null, null);
		if (cursor.moveToFirst()) {
			return true;
		}
		return false;
	}

	@Override
	public void clearTable() {
		super.clearTable();
		new ExpenseTableAdapter(mContext).clearTable();
	}
}
