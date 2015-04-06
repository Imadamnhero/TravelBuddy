package sdc.net.webservice;

import java.util.ArrayList;
import java.util.List;

import org.apache.http.NameValuePair;
import org.apache.http.message.BasicNameValuePair;
import org.json.JSONException;
import org.json.JSONObject;

import sdc.data.User;
import sdc.data.database.adapter.UserTableAdapter;
import sdc.net.listeners.IWebServiceListener;
import android.content.Context;

public class AddGroupWS extends BaseWS<String> {
	private Context mContext;

	public AddGroupWS(IWebServiceListener listener, Context context) {
		super(listener, BaseWS.ADD_GROUP);
		mContext = context;
	}

	@Override
	public String parseData(String json) {
		try {
			JSONObject obj = new JSONObject(json);
			int success = obj.getInt("success");
			if (success == 1) {
				String nameNewMem = obj.getString("member");
				String avaNewMem = obj.getString("memberava");
				int idNewMem = obj.getInt("newmember_id");
				new UserTableAdapter(mContext).updateUser(new User(idNewMem,
						avaNewMem, nameNewMem));
			}
			return obj.getString("message");
		} catch (JSONException e) {
		}
		return null;
	}

	public void fetchData(int inviter_userid, String invited_email) {
		List<NameValuePair> data = new ArrayList<NameValuePair>();
		data.add(new BasicNameValuePair("userid", String
				.valueOf(inviter_userid)));
		data.add(new BasicNameValuePair("email", invited_email));
		super.fetch(data);
	}

}
