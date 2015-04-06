package sdc.net.webservice;

import java.util.ArrayList;
import java.util.List;

import org.apache.http.NameValuePair;
import org.apache.http.message.BasicNameValuePair;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import sdc.data.PackingItem;
import sdc.net.listeners.IWebServiceListener;

public class GetPremadeItemWS extends BaseWS<List<PackingItem>> {

	public GetPremadeItemWS(IWebServiceListener listener) {
		super(listener, BaseWS.GET_PREMADE_ITEM);
	}

	@Override
	public List<PackingItem> parseData(String json) {
		try {
			JSONObject obj = new JSONObject(json);
			JSONArray arr = obj.getJSONArray("data");
			List<PackingItem> listPack = new ArrayList<PackingItem>();
			for (int i = 0; i < arr.length(); i++) {
				JSONObject packing = arr.getJSONObject(i);
				int id = packing.getInt("id");
				String item = packing.getString("item");
				int listId = packing.getInt("listid");
				listPack.add(new PackingItem(-1, item, listId, id));
			}
			return listPack;
		} catch (JSONException e) {
		}
		return null;
	}

	public void fetchData() {
		List<NameValuePair> data = new ArrayList<NameValuePair>();
		data.add(new BasicNameValuePair("", ""));
		super.fetch(data);
	}
}