package sdc.net.webservice;

import java.util.ArrayList;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.os.AsyncTask.Status;

import sdc.data.Expense;
import sdc.net.listeners.IWebServiceListener;

public class SyncExpensesWS extends BaseSyncWS<List<Expense>> {
	private static SyncExpensesWS mInstance;

	private SyncExpensesWS() {
		super(null, BaseWS.SYNC_EXPENSE);
	}

	public static SyncExpensesWS getInstance() {
		if (mInstance == null) {
			mInstance = new SyncExpensesWS();
		}
		return mInstance;
	}

	@Override
	public List<Expense> parseData(String json) {
		try {
			JSONObject obj = new JSONObject(json);
			JSONArray arrNewExpenses = obj.getJSONArray("updated_data");
			List<Expense> result = new ArrayList<Expense>();
			for (int i = 0; i < arrNewExpenses.length(); i++) {
				JSONObject objExpense = arrNewExpenses.getJSONObject(i);
				int serverId = objExpense.getInt("serverid");
				int cateId = objExpense.getInt("cateid");
				String item = objExpense.getString("item");
				String time = objExpense.getString("time");
				int ownerId = objExpense.getInt("ownerid");
				int flag = objExpense.getInt("flag");
				float money = (float) objExpense.getDouble("money");
				Expense expense = new Expense(-1, cateId, item, money, time, ownerId,
						serverId, flag);
				result.add(expense);
			}
			return result;
		} catch (JSONException e) {
		}
		return null;
	}

	public boolean isLoading() {
		if (this.mJSONTask == null || this.mJSONTask.isCancelled()
				|| this.mJSONTask.getStatus() == Status.FINISHED) {
			return false;
		} else {
			return true;
		}
	}

	public void fetchData(IWebServiceListener listener, int clientVer,
			JSONArray uploadData, int userId) {
		this.mListener = listener;
		JSONObject obj = new JSONObject();
		try {
			obj.put("client_ver", clientVer);
			obj.put("data", uploadData);
			obj.put("ownerid", userId);
			super.fetch(obj);
		} catch (JSONException e) {
			e.printStackTrace();
		}
	}

}
