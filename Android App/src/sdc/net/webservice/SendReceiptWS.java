package sdc.net.webservice;

import java.util.ArrayList;
import java.util.List;

import org.apache.http.NameValuePair;
import org.apache.http.message.BasicNameValuePair;
import org.json.JSONException;
import org.json.JSONObject;

import sdc.net.listeners.IWebServiceListener;

public class SendReceiptWS extends BaseWS<String> {

	public SendReceiptWS(IWebServiceListener listener) {
		super(listener, BaseWS.SEND_RECEIPT);
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

	public void fetchData(int userId, String emailreceived, int sent2owner,
			String photoIds) {
		List<NameValuePair> values = new ArrayList<NameValuePair>();
		values.add(new BasicNameValuePair("userid", String.valueOf(userId)));
		values.add(new BasicNameValuePair("email", emailreceived));
		values.add(new BasicNameValuePair("sent2owner", String
				.valueOf(sent2owner)));
		values.add(new BasicNameValuePair("receipt_ids", photoIds));
		super.fetch(values);
	}
}
