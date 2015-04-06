package sdc.net.webservice;

import java.util.ArrayList;
import java.util.List;

import org.apache.http.NameValuePair;
import org.apache.http.message.BasicNameValuePair;
import org.json.JSONException;
import org.json.JSONObject;

import sdc.net.listeners.IWebServiceListener;

public class AddTripWS extends BaseWS<Integer> {

	public AddTripWS(IWebServiceListener listener) {
		super(listener, BaseWS.ADD_TRIP);
	}

	@Override
	public Integer parseData(String json) {
		try {
			JSONObject obj = new JSONObject(json);
			int success = obj.getInt("success");
			if (success == 0) {
			} else if (success == 1) {
				return obj.getInt("tripid");
			}
		} catch (JSONException e) {
			e.printStackTrace();
		}
		return -1;
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

	public void fetchData(String name, int userId, String fromDate,
			String toDate, double budget) {
		List<NameValuePair> data = new ArrayList<NameValuePair>();
		data.add(new BasicNameValuePair("userid", String.valueOf(userId)));
		data.add(new BasicNameValuePair("tripname", name));
		data.add(new BasicNameValuePair("start_date", fromDate));
		data.add(new BasicNameValuePair("finish_date", toDate));
		data.add(new BasicNameValuePair("trip_budget", String.valueOf(budget)));
		fetch(data);
	}

}
