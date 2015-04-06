package sdc.net.webservice;

import java.util.ArrayList;
import java.util.List;

import org.apache.http.NameValuePair;
import org.apache.http.message.BasicNameValuePair;
import org.json.JSONException;
import org.json.JSONObject;

import sdc.net.listeners.IWebServiceListener;

public class AddBudgetWS extends BaseWS<Double> {

	public AddBudgetWS(IWebServiceListener listener) {
		super(listener, BaseWS.ADD_BUDGET);
		
		// TODO Auto-generated constructor stub
	}

	@Override
	public Double parseData(String json) {
		try {
			JSONObject obj = new JSONObject(json);
			int success = obj.getInt("success");
			if (success == 0) {
				return -1.0;
			} else if (success == 1) {
				return obj.getDouble("budget");
			}
		} catch (JSONException e) {
			e.printStackTrace();
		}
		return -1.0;
	}
	public static String parseFaultMessage(String json) {
		try {
			JSONObject obj = new JSONObject(json);
			int success = obj.getInt("success");
			if (success == 0) {
				return obj.getString("message");
			}
		} catch (JSONException e) {
			e.printStackTrace();
		}
		return "Uncaught problem";
	}
	public void fetchData(int userId, double budget) {
		List<NameValuePair> data = new ArrayList<NameValuePair>();
		data.add(new BasicNameValuePair("userid", String.valueOf(userId)));
		data.add(new BasicNameValuePair("budget", String.valueOf(budget)));
		fetch(data);
	}
}
