package sdc.net.webservice;

import java.util.ArrayList;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import sdc.data.User;
import sdc.net.listeners.IWebServiceListener;

public class GetUserDataWS extends BaseWS<List<User>> {

	public GetUserDataWS(IWebServiceListener listener) {
		super(listener, BaseWS.GET_USER_INFO);
	}

	@Override
	public List<User> parseData(String json) {
		try {
			JSONObject o = new JSONObject(json);
			if (o.getInt("success") == 1) {
				JSONArray arr = o.getJSONArray("data");
				List<User> result = new ArrayList<User>();
				for (int i = 0; i < arr.length(); i++) {
					JSONObject obj = arr.getJSONObject(i);
					int id = obj.getInt("userid");
					String username = obj.getString("username");
					String avatar = obj.getString("avatarurl");
					result.add(new User(id, avatar, username));
				}
				return result;
			}
		} catch (JSONException e) {
		}
		return null;
	}

	public void fetchData(List<Integer> listId) {
		if (listId != null) {
			JSONArray arr = new JSONArray();
			for (Integer id : listId) {
				arr.put(id);
			}
			JSONObject data = new JSONObject();
			try {
				data.put("listid", arr);
			} catch (JSONException e) {
				e.printStackTrace();
			}
			fetch(data);
		}
	}
}
