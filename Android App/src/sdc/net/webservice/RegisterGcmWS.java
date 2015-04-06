package sdc.net.webservice;

import java.util.ArrayList;
import java.util.List;

import org.apache.http.NameValuePair;
import org.apache.http.message.BasicNameValuePair;
import org.json.JSONException;
import org.json.JSONObject;

import sdc.net.listeners.IWebServiceListener;

public class RegisterGcmWS extends BaseWS<String> {

	public RegisterGcmWS(IWebServiceListener listener) {
		super(listener, BaseWS.REGISTER_GCM);
	}

	@Override
	public String parseData(String json) {
		try {
			JSONObject obj = new JSONObject(json);
			int success = obj.getInt("success");
			if (success == 1) {
				return obj.getString("message");
			}
		} catch (JSONException e) {
		}
		return null;
	}

	public void fetchData(int userId, String regId) {
		List<NameValuePair> data = new ArrayList<NameValuePair>();
		data.add(new BasicNameValuePair("userid", String.valueOf(userId)));
		data.add(new BasicNameValuePair("gcm_reg", regId));
		data.add(new BasicNameValuePair("os", String.valueOf(1)));
		super.fetch(data);
	}

}
