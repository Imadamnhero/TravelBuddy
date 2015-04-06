package sdc.net.webservice;

import java.util.ArrayList;
import java.util.List;

import org.apache.http.NameValuePair;
import org.apache.http.message.BasicNameValuePair;
import org.json.JSONException;
import org.json.JSONObject;

import sdc.data.Trip;
import sdc.net.listeners.IWebServiceListener;

public class GetTripWS extends BaseWS<Trip>{
	
	public GetTripWS(IWebServiceListener listener) {
		super(listener, BaseWS.GET_TRIP);
	}
	
	@Override
	public Trip parseData(String json) {
		try {
			JSONObject obj = new JSONObject(json);
			int success = obj.getInt("success");
			if(success == 0){
				return null;
			} else if(success == 1){
				String tripname = obj.getString("tripname");
				String startdate = obj.getString("start_date");
				String enddate = obj.getString("finish_date");
				double budget = obj.getDouble("budget");
				int ownerId = obj.getInt("ownerid");
				int groupPhotos = obj.getInt("photo_count");
				return new Trip(0, ownerId, 0, tripname, startdate, enddate, budget, groupPhotos);
			}
		} catch (JSONException e) {
			e.printStackTrace();
		}
		return null;
	}
	
	public void fetchData(int tripId, int userId){
		List<NameValuePair> data = new ArrayList<NameValuePair>();
		data.add(new BasicNameValuePair("tripid", String.valueOf(tripId)));
		data.add(new BasicNameValuePair("userid", String.valueOf(userId)));
		super.fetch(data);
	}
}
