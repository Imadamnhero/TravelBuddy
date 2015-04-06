package sdc.net.webservice;

import java.util.ArrayList;
import java.util.List;

import org.apache.http.NameValuePair;
import org.apache.http.message.BasicNameValuePair;
import org.json.JSONException;
import org.json.JSONObject;

import android.util.Pair;
import sdc.net.listeners.IWebServiceListener;

public class EndTripWS extends BaseWS<Pair<Integer, String>> {

	public EndTripWS(IWebServiceListener listener) {
		super(listener, BaseWS.END_TRIP);
	}

	@Override
	public Pair<Integer, String> parseData(String json) {
		try {
			JSONObject obj = new JSONObject(json);
			int success = obj.getInt("success");
			String message = obj.getString("message");
			return new Pair<Integer, String>(success, message);
		} catch (JSONException e) {
			e.printStackTrace();
		}
		return null;
	}

	public void fetchData(int tripid, int userid) {
		List<NameValuePair> data = new ArrayList<NameValuePair>();
		data.add(new BasicNameValuePair("tripid", String.valueOf(tripid)));
		data.add(new BasicNameValuePair("userid", String.valueOf(userid)));
		fetch(data);
	}
}
