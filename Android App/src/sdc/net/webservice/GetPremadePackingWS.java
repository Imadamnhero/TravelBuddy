package sdc.net.webservice;

import java.util.ArrayList;
import java.util.List;

import org.apache.http.NameValuePair;
import org.apache.http.message.BasicNameValuePair;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import sdc.data.Packing;
import sdc.net.listeners.IWebServiceListener;

public class GetPremadePackingWS extends BaseWS<List<Packing>> {

	public GetPremadePackingWS(IWebServiceListener listener) {
		super(listener, BaseWS.GET_PREMADE_LIST);
	}

	@Override
	public List<Packing> parseData(String json) {
		try{
			JSONObject obj = new JSONObject(json);
			JSONArray arr = obj.getJSONArray("data");
			List<Packing> listPack = new ArrayList<Packing>();
			for (int i = 0; i < arr.length(); i++) {
				JSONObject packing = arr.getJSONObject(i);
				int id = packing.getInt("id");
				String title = packing.getString("title");
				listPack.add(new Packing(id, title, -1));
			}
			return listPack;
		} catch(JSONException e){
		}
		return null;
	}

	public void fetchData() {
		List<NameValuePair> data = new ArrayList<NameValuePair>();
		data.add(new BasicNameValuePair("", ""));
		super.fetch(data);
	}
}
