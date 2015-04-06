package sdc.net.webservice;

import java.util.ArrayList;
import java.util.List;

import org.apache.http.NameValuePair;
import org.apache.http.message.BasicNameValuePair;
import org.json.JSONException;
import org.json.JSONObject;

import sdc.net.listeners.IWebServiceListener;

public class RemoveGcmWS extends BaseWS<String>{
	
	public RemoveGcmWS(IWebServiceListener listener) {
		super(listener, BaseWS.REMOVE_GCM);
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
	
	public void fetchData(String regId){
		List<NameValuePair> data = new ArrayList<NameValuePair>();
		data.add(new BasicNameValuePair("gcmid", regId));
		super.fetch(data);
	}
}
