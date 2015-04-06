package sdc.net.webservice;

import java.util.ArrayList;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import sdc.net.listeners.IWebServiceListener;
import android.util.Pair;

public abstract class BaseSyncWS<T> extends BaseWS<T> {

	public BaseSyncWS(IWebServiceListener listener, int typeOfService) {
		super(listener, typeOfService);
	}

	/**
	 * return new record from server
	 */
	@Override
	public abstract T parseData(String json);

	/**
	 * return newest version of note on server
	 * 
	 * @param json
	 * @return
	 */
	public int parseNewVersion(String json) {
		try {
			JSONObject obj = new JSONObject(json);
			return obj.getInt("new_ver");
		} catch (JSONException e) {
		}
		return -1;
	}

	/**
	 * return new serverId use to update client table
	 * 
	 * @param json
	 * @return
	 */
	public List<Pair<Integer, Integer>> parseNewServerId(String json) {
		try {
			JSONObject obj = new JSONObject(json);
			JSONArray arr = obj.getJSONArray("committed_id");
			List<Pair<Integer, Integer>> result = new ArrayList<Pair<Integer, Integer>>();
			for (int i = 0; i < arr.length(); i++) {
				JSONObject jsonObj = arr.getJSONObject(i);
				int clientId = jsonObj.getInt("clientid");
				int serverId = jsonObj.getInt("serverid");
				result.add(new Pair<Integer, Integer>(clientId, serverId));
			}
			return result;
		} catch (JSONException e) {
		}
		return null;
	}

	/**
	 * Return message of failure
	 * 
	 * @param json
	 * @return
	 */
	public String parseFaultMessage(String json) {
		try {
			JSONObject obj = new JSONObject(json);
			return obj.getString("message");
		} catch (JSONException e) {
		}
		return "Fault on server";
	}

}
