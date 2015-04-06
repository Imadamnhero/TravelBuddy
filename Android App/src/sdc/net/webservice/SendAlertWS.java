package sdc.net.webservice;

import java.util.List;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import sdc.net.listeners.IWebServiceListener;

public class SendAlertWS extends BaseWS<String> {

	public SendAlertWS(IWebServiceListener listener) {
		super(listener, BaseWS.SEND_ALERT);
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

	public void fetchData(int senderId, List<Integer> receiverId, String content) {
		JSONObject data = new JSONObject();
		try {
			data.put("senderid", senderId);
			data.put("content", content);
			JSONArray arr = new JSONArray();
			for (int id: receiverId) {
				arr.put(id);
			}
			data.put("receiverid", arr);
			super.fetch(data);
		} catch (JSONException e) {
			e.printStackTrace();
		}
	}
	
}
