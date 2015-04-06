package sdc.net.webservice;

import java.util.ArrayList;
import java.util.List;

import org.apache.http.NameValuePair;
import org.apache.http.message.BasicNameValuePair;
import org.json.JSONException;
import org.json.JSONObject;

import sdc.net.listeners.IWebServiceListener;

public class SendMailInviteWS extends BaseWS<String> {

	public SendMailInviteWS(IWebServiceListener listener) {
		super(listener, BaseWS.SEND_MAIL_INVITE);
	}

	@Override
	public String parseData(String json) {
		try {
			JSONObject obj = new JSONObject(json);
			return obj.getString("message");
		} catch (JSONException e) {
		}
		return null;
	}

	public void fetchData(int userId, String emailreceived) {
		List<NameValuePair> values = new ArrayList<NameValuePair>();
		values.add(new BasicNameValuePair("userid", String.valueOf(userId)));
		values.add(new BasicNameValuePair("email", emailreceived));
		super.fetch(values);
	}
}
