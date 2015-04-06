package sdc.net.webservice;

import java.util.ArrayList;
import java.util.List;

import org.apache.http.NameValuePair;
import org.apache.http.message.BasicNameValuePair;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import sdc.application.TravelPrefs;
import sdc.data.User;
import sdc.data.database.ContentProviderDB;
import sdc.data.database.adapter.UserTableAdapter;
import sdc.data.database.adapter.UsersInGroupTableAdapter;
import sdc.data.database.adapter.VersionTableAdapter;
import sdc.net.listeners.IWebServiceListener;
import android.content.Context;

public class GetUsersInGroupWS extends BaseWS<String> {
	private Context mContext;

	public GetUsersInGroupWS(IWebServiceListener listener, Context context) {
		super(listener, BaseWS.GET_USERS_IN_GROUP);
		mContext = context;
	}

	@Override
	public String parseData(String json) {
		try {
			JSONObject obj = new JSONObject(json);
			int success = obj.getInt("success");
			if (success == 1) {
				int tripId = (Integer) TravelPrefs.getData(mContext,
						TravelPrefs.PREF_TRIP_ID);
				int curUserId = (Integer) TravelPrefs.getData(mContext,
						TravelPrefs.PREF_USER_ID);
				JSONArray arr = obj.getJSONArray("updated_data");
				UserTableAdapter userTableAdapter = new UserTableAdapter(
						mContext);
				UsersInGroupTableAdapter usersInGroupTableAdapter = new UsersInGroupTableAdapter(
						mContext);
				usersInGroupTableAdapter.deleteUsersInTrip(tripId);
				for (int i = 0; i < arr.length(); i++) {

					JSONObject userObj = arr.getJSONObject(i);
					int userId = userObj.getInt("userid");
					String userName = userObj.getString("username");
					String userAvatar = userObj.getString("avatarurl");
					int pendingStt = userObj.getInt("pendingstt");
					// update user info table
					userTableAdapter.updateUser(new User(userId, userAvatar,
							userName));
					// update user in group table
					usersInGroupTableAdapter.addUserToGroup(
							userId, tripId, pendingStt);
				}
				int newVer = obj.getInt("new_ver");
				new VersionTableAdapter(mContext).setVersionTableOfUser(
						ContentProviderDB.COL_VERSION_GROUP, newVer, curUserId);
				return null;
			}
			return obj.getString("message");
		} catch (JSONException e) {
			return e.getMessage();
		}
	}

	public void fetchData(int tripId, int clientVer) {
		List<NameValuePair> data = new ArrayList<NameValuePair>();
		data.add(new BasicNameValuePair("tripid", String.valueOf(tripId)));
		data.add(new BasicNameValuePair("client_ver", String.valueOf(clientVer)));
		super.fetch(data);
	}
}
