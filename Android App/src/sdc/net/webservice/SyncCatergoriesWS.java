package sdc.net.webservice;

import java.util.ArrayList;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import sdc.data.Category;
import sdc.net.listeners.IWebServiceListener;
import android.os.AsyncTask.Status;

public class SyncCatergoriesWS extends BaseSyncWS<List<Category>> {
	private static SyncCatergoriesWS mInstance;

	private SyncCatergoriesWS() {
		super(null, BaseWS.SYNC_CATEGORIES);
	}

	public static SyncCatergoriesWS getInstance() {
		if (mInstance == null) {
			mInstance = new SyncCatergoriesWS();
		}
		return mInstance;
	}

	@Override
	public List<Category> parseData(String json) {
		try {
			JSONObject obj = new JSONObject(json);
			JSONArray arrNewExpenses = obj.getJSONArray("updated_data");
			List<Category> result = new ArrayList<Category>();
			for (int i = 0; i < arrNewExpenses.length(); i++) {
				JSONObject objExpense = arrNewExpenses.getJSONObject(i);
				int serverId = objExpense.getInt("serverid");
				String name = objExpense.getString("name");
				int userId = objExpense.getInt("user_id");
				int flag = objExpense.getInt("flag");
				Category category = new Category(serverId, name);
				category.setFlag(flag);
				category.setUserId(userId);
				result.add(category);
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
