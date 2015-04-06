package sdc.net.webservice;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import org.apache.http.NameValuePair;
import org.apache.http.message.BasicNameValuePair;
import org.json.JSONException;
import org.json.JSONObject;

import sdc.net.listeners.IWebServiceListener;

public class GetVersionWS extends BaseWS<HashMap<String, Integer>> {

	public GetVersionWS(IWebServiceListener listener) {
		super(listener, BaseWS.GET_VERSION);
	}

	@Override
	public HashMap<String, Integer> parseData(String json) {
		try {
			JSONObject obj = new JSONObject(json);
			int success = obj.getInt("success");
			if (success == 1) {
				String[] arrKey = { "note_ver", "cate_ver", "expense_ver",
						"group_ver", "photo_ver", "packingtitle_ver",
						"packingitem_ver", "premadelist_ver", "premadeitem_ver" };
				HashMap<String, Integer> result = new HashMap<String, Integer>();
				for (String key : arrKey) {
					result.put(key, obj.getInt(key));
				}
				return result;
			} else if(success == 0){
				return null;
			}
		} catch (JSONException e) {
		}
		return null;
	}

	public void fetchData(int userId, int tripId) {
		List<NameValuePair> data = new ArrayList<NameValuePair>();
		data.add(new BasicNameValuePair("userid", String.valueOf(userId)));
		data.add(new BasicNameValuePair("tripid", String.valueOf(tripId)));
		fetch(data);
	}
}
