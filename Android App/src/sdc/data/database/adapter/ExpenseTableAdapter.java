package sdc.data.database.adapter;

import java.util.ArrayList;
import java.util.List;

import sdc.data.Expense;
import sdc.data.database.ContentProviderDB;
import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;

public class ExpenseTableAdapter extends BaseTableAdapter {

	public static final String TABLE_NAME = ContentProviderDB.PREFIX
			+ "expenses";
	public static final String CREATE_TABLE = "CREATE TABLE IF NOT EXISTS "
			+ TABLE_NAME + " (" + ContentProviderDB.COL_ID
			+ " integer primary key autoincrement, "
			+ ContentProviderDB.COL_CATE_ID + " integer default 0, "
			+ ContentProviderDB.COL_LOCAL_CATE_ID + " integer, "
			+ ContentProviderDB.COL_EXPENSE_DATETIME + " text, "
			+ ContentProviderDB.COL_EXPENSE_MONEY + " real, "
			+ ContentProviderDB.COL_EXPENSE_ITEM + " text, "
			+ ContentProviderDB.COL_OWNER + " integer, "
			+ ContentProviderDB.COL_SERVER_ID + " integer, "
			+ ContentProviderDB.COL_FLAG + " integer)";

	public ExpenseTableAdapter(Context context) {
		super(context, TABLE_NAME);
	}

	public void addExpense(Expense expense, int ownerId, int serverId, int flag) {
		ContentValues values = new ContentValues();
		values.put(ContentProviderDB.COL_CATE_ID, expense.getCateId());
		values.put(ContentProviderDB.COL_LOCAL_CATE_ID,
				expense.getLocalCateId());
		values.put(ContentProviderDB.COL_EXPENSE_DATETIME, expense.getDate());
		values.put(ContentProviderDB.COL_EXPENSE_MONEY, expense.getMoney());
		values.put(ContentProviderDB.COL_EXPENSE_ITEM, expense.getItem());
		values.put(ContentProviderDB.COL_OWNER, ownerId);
		values.put(ContentProviderDB.COL_SERVER_ID, serverId);
		values.put(ContentProviderDB.COL_FLAG, flag);
		super.insert(values);
	}

	public void updateExpense(Expense expense, int ownerId, int serverId) {
		ContentValues values = new ContentValues();
		values.put(ContentProviderDB.COL_CATE_ID, expense.getCateId());
		values.put(ContentProviderDB.COL_LOCAL_CATE_ID,
				expense.getLocalCateId());
		values.put(ContentProviderDB.COL_EXPENSE_DATETIME, expense.getDate());
		values.put(ContentProviderDB.COL_EXPENSE_MONEY, expense.getMoney());
		values.put(ContentProviderDB.COL_EXPENSE_ITEM, expense.getItem());
		values.put(ContentProviderDB.COL_OWNER, ownerId);
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

	public List<Expense> getExpenseOfUser(int userId) {
		Cursor cursor = super.query(null, ContentProviderDB.COL_OWNER + "="
				+ userId + " AND " + ContentProviderDB.COL_FLAG + " <> "
				+ ContentProviderDB.FLAG_DEL, null, null);
		if (cursor.moveToFirst()) {
			List<Expense> listExpense = new ArrayList<Expense>();
			do {
				int id = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_ID));
				String date = cursor
						.getString(cursor
								.getColumnIndex(ContentProviderDB.COL_EXPENSE_DATETIME));
				Float money = cursor.getFloat(cursor
						.getColumnIndex(ContentProviderDB.COL_EXPENSE_MONEY));
				String item = cursor.getString(cursor
						.getColumnIndex(ContentProviderDB.COL_EXPENSE_ITEM));
				int cateId = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_CATE_ID));
				int ownerId = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_OWNER));
				int serverId = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_SERVER_ID));
				int localId = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_LOCAL_CATE_ID));
				int flag = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_FLAG));
				Expense expense = new Expense(id, cateId, item, money, date,
						ownerId, serverId, flag);
				expense.setLocalCateId(localId);
				listExpense.add(expense);
			} while (cursor.moveToNext());
			return listExpense;
		}
		return null;
	}

	public void deleteExpenseOfUser(int userId) {
		super.delete(ContentProviderDB.COL_OWNER + "=" + userId, null);
	}

	public void deleteExpenseOfCategory(int categoryId) {
		super.delete(ContentProviderDB.COL_LOCAL_CATE_ID + "=" + categoryId,
				null);
	}
	public void deleteExpenseOfServerCategory(int categoryId) {
		super.delete(ContentProviderDB.COL_CATE_ID + "=" + categoryId,
				null);
	}
	public void handleDataFromServer(List<Expense> listExpense) {
		for (Expense expense : listExpense) {
			if (expense.getFlag() == ContentProviderDB.FLAG_EDIT
					|| expense.getFlag() == ContentProviderDB.FLAG_ADD) {
				expense.setLocalCateId(new CategoryTableAdapter(getContext())
						.getLocalCatId(expense.getCateId()));
				insertOrUpdateExpense(expense, expense.getServerId());
			} else {
				super.delete(
						ContentProviderDB.COL_SERVER_ID + "="
								+ expense.getServerId(), null);
			}
		}
	}

	/**
	 * If a row from server is exist in table, that row will be updated. If not
	 * exist, it will be inserted
	 * 
	 * @param note
	 * @param serverId
	 * @param tripId
	 */
	public void insertOrUpdateExpense(Expense expense, int serverId) {
		ContentValues values = new ContentValues();
		values.put(ContentProviderDB.COL_CATE_ID, expense.getCateId());
		values.put(ContentProviderDB.COL_LOCAL_CATE_ID,
				expense.getLocalCateId());
		values.put(ContentProviderDB.COL_EXPENSE_DATETIME, expense.getDate());
		values.put(ContentProviderDB.COL_EXPENSE_MONEY, expense.getMoney());
		values.put(ContentProviderDB.COL_EXPENSE_ITEM, expense.getItem());
		values.put(ContentProviderDB.COL_OWNER, expense.getOwnerId());
		values.put(ContentProviderDB.COL_SERVER_ID, serverId);
		values.put(ContentProviderDB.COL_FLAG, ContentProviderDB.FLAG_NONE);
		if (super.update(values, ContentProviderDB.COL_SERVER_ID + "="
				+ serverId, null) <= 0) {
			super.insert(values);
		}
	}

	public void updateServerId(int localId, int serverId) {
		ContentValues values = new ContentValues();
		values.put(ContentProviderDB.COL_SERVER_ID, serverId);
		super.update(values, ContentProviderDB.COL_ID + "=" + localId, null);
	}

	public void updateCategorySeverId(int localCatId, int serverCatId) {
		ContentValues values = new ContentValues();
		values.put(ContentProviderDB.COL_CATE_ID, serverCatId);
		super.update(values, ContentProviderDB.COL_LOCAL_CATE_ID + "="
				+ localCatId, null);
	}

	public List<Expense> getExpensesNeedUpload() {
		Cursor cursor = super.query(null, ContentProviderDB.COL_FLAG + " <> "
				+ ContentProviderDB.FLAG_NONE + " AND "
				+ ContentProviderDB.COL_CATE_ID + "<>0", null, null);
		if (cursor.moveToFirst()) {
			List<Expense> listExpense = new ArrayList<Expense>();
			do {
				int id = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_ID));
				int cateId = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_CATE_ID));
				String item = cursor.getString(cursor
						.getColumnIndex(ContentProviderDB.COL_EXPENSE_ITEM));
				String datetime = cursor
						.getString(cursor
								.getColumnIndex(ContentProviderDB.COL_EXPENSE_DATETIME));
				float money = cursor.getFloat(cursor
						.getColumnIndex(ContentProviderDB.COL_EXPENSE_MONEY));
				int ownerId = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_OWNER));
				int serverId = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_SERVER_ID));
				int flag = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_FLAG));

				listExpense.add(new Expense(id, cateId, item, money, datetime,
						ownerId, serverId, flag));
			} while (cursor.moveToNext());
			return listExpense;
		}
		return null;
	}

}