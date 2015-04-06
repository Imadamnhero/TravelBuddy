package sdc.net.webservice;

import java.util.ArrayList;
import java.util.List;

import org.apache.http.NameValuePair;
import org.apache.http.message.BasicNameValuePair;
import org.json.JSONException;
import org.json.JSONObject;

import sdc.net.listeners.IWebServiceListener;

public class EditTripNameWS extends BaseWS<String> {

	public EditTripNameWS(IWebServiceListener listener) {
		super(listener, BaseWS.EDIT_TRIPNAME);
	}

	@Override
	public String parseData(String json) {
		try {
			JSONObject obj = new JSONObject(json);
			if (obj.getInt("success") == 1) {
				return obj.getString("tripname");
			}
		} catch (JSONException e) {

		}
		return null;
	}

	public void fetchData(String newName, int userId) {
		List<NameValuePair> data = new ArrayList<NameValuePair>();
		data.add(new BasicNameValuePair("userid", String.valueOf(userId)));
		data.add(new BasicNameValuePair("new_tripname", newName));
		fetch(data);
	}
}
