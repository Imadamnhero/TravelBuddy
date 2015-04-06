package sdc.net.webservice;

import java.util.ArrayList;
import java.util.List;

import org.apache.http.NameValuePair;
import org.apache.http.message.BasicNameValuePair;
import org.json.JSONException;
import org.json.JSONObject;

import sdc.net.listeners.IWebServiceListener;
import android.util.Pair;

public class ForgotPassWS extends BaseWS<Pair<Integer, String>> {

	public ForgotPassWS(IWebServiceListener listener) {
		super(listener, BaseWS.FORGOT_PASS);
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

	public void fetchData(String email) {
		List<NameValuePair> data = new ArrayList<NameValuePair>();
		data.add(new BasicNameValuePair("email", email));
		super.fetch(data);
	}

}
