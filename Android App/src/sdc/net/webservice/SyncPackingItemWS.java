package sdc.net.webservice;

import java.util.ArrayList;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import sdc.data.PackingItem;
import sdc.net.listeners.IWebServiceListener;

public class SyncPackingItemWS extends BaseSyncWS<List<PackingItem>> {

	public SyncPackingItemWS(IWebServiceListener listener) {
		super(listener, BaseWS.SYNC_PACKING_ITEM);
	}

	@Override
	public List<PackingItem> parseData(String json) {
		try {
			JSONObject obj = new JSONObject(json);
			if (obj.getInt("success") == 1) {
				JSONArray arr = obj.getJSONArray("updated_data");
				List<PackingItem> listPack = new ArrayList<PackingItem>();
				for (int i = 0; i < arr.length(); i++) {
					JSONObject pack = arr.getJSONObject(i);
					int serverId = pack.getInt("serverid");
					String item = pack.getString("item");
					int isCheck = pack.getInt("ischecked");
					int listId = pack.getInt("listid");
					int flag = pack.getInt("flag");
					listPack.add(new PackingItem(-1, item, listId,
							isCheck == 1 ? true : false, serverId, flag));
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
