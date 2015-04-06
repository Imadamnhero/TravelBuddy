package sdc.net.webservice;

import java.util.ArrayList;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import sdc.data.Packing;
import sdc.net.listeners.IWebServiceListener;

public class SyncPackingWS extends BaseSyncWS<List<Packing>> {

	public SyncPackingWS(IWebServiceListener listener) {
		super(listener, BaseWS.SYNC_PACKING_LIST);
	}

	@Override
	public List<Packing> parseData(String json) {
		try {
			JSONObject obj = new JSONObject(json);
			if (obj.getInt("success") == 1) {
				JSONArray arr = obj.getJSONArray("updated_data");
				List<Packing> listPack = new ArrayList<Packing>();
				for (int i = 0; i < arr.length(); i++) {
					JSONObject pack = arr.getJSONObject(i);
					int serverId = pack.getInt("serverid");
					String title = pack.getString("title");
					int ownerId = pack.getInt("ownerid");
					int flag = pack.getInt("flag");
					listPack.add(new Packing(-1, title, ownerId, serverId, flag));
				}
				return listPack;
			}
		} catch (JSONException e) {
		}
		return null;
	}

	public void fetchData(int clientVer, JSONArray uploadData, int userId) {
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
