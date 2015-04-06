package sdc.net.webservice;

import java.util.ArrayList;
import java.util.List;

import org.apache.http.NameValuePair;
import org.apache.http.message.BasicNameValuePair;
import org.json.JSONException;
import org.json.JSONObject;

import sdc.net.listeners.IWebServiceListener;

public class ReplyInvitationWS extends BaseWS<String> {

	public ReplyInvitationWS(IWebServiceListener listener) {
		super(listener, BaseWS.REPLY_INVITE);
	}

	@Override
	public String parseData(String json) {
		try {
			JSONObject obj = new JSONObject(json);
			int success = obj.getInt("success");
			if (success == 1) {
				return "";
			} else {
				return obj.getString("message");
			}
		} catch (JSONException e) {
		}
		return null;
	}

	/**
	 * @param reply
	 *            =0: cancel and =1: accept
	 */
	public void fetchData(int inviterId, int invitedId, int tripId, int reply) {
		List<NameValuePair> data = new ArrayList<NameValuePair>();
		data.add(new BasicNameValuePair("invited_user_id", String
				.valueOf(invitedId)));
		data.add(new BasicNameValuePair("inviter_id", String.valueOf(inviterId)));
		data.add(new BasicNameValuePair("invited_tripid", String
				.valueOf(tripId)));
		data.add(new BasicNameValuePair("reply", String.valueOf(reply))); 
		super.fetch(data);
	}
}