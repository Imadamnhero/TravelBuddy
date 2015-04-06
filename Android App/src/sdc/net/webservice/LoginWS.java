package sdc.net.webservice;

import java.util.ArrayList;
import java.util.List;

import org.apache.http.NameValuePair;
import org.apache.http.message.BasicNameValuePair;
import org.json.JSONException;
import org.json.JSONObject;

import sdc.application.TravelPrefs;
import sdc.data.User;
import sdc.net.listeners.IWebServiceListener;
import sdc.travelapp.GCMUtils;
import android.content.Context;

import com.google.android.gcm.GCMRegistrar;

public class LoginWS extends BaseWS<User> {
	private Context mContext;
	private IWebServiceListener mListener;
	private String mMail, mPass;

	public LoginWS(IWebServiceListener listener, Context context) {
		super(listener, BaseWS.LOGIN);
		mContext = context;
		mListener = listener;
	}

	@Override
	public User parseData(String json) {
		JSONObject obj;
		try {
			obj = new JSONObject(json);
			int success = obj.getInt("success");
			if (success == 1) {
				if (obj.getString("gcmid").equals("")) {
					GCMUtils.takeOrPostGcmId(mContext, mListener);
				}
				boolean isRememberPass = (Boolean) TravelPrefs.getData(
						mContext, TravelPrefs.PREF_REMEMBER);
				if (mMail != null && mPass != null && isRememberPass) {
					TravelPrefs.putData(mContext, TravelPrefs.PREF_USER_MAIL,
							mMail);
					TravelPrefs.putData(mContext, TravelPrefs.PREF_USER_PASS,
							mPass);
				}
				return new User(obj.getInt("userid"), BaseWS.HOST
						+ obj.getString("avatarurl"),
						obj.getString("username"),
						obj.getString("tripid") != null ? obj.getInt("tripid")
								: -1, obj.getString("tripname"));
			} else {
				// login fail
				new RemoveGcmWS(null).fetchData(GCMRegistrar
						.getRegistrationId(mContext));
			}
		} catch (JSONException e) {
			e.printStackTrace();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}

	public static String parseFaultMessage(String json) {
		JSONObject obj;
		try {
			obj = new JSONObject(json);
			if (obj.getInt("success") == 0) {
				return obj.getString("message");
			}
		} catch (JSONException e) {
			e.printStackTrace();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return "";
	}

	public void fetchData(String email, String pass) {
		List<NameValuePair> data = new ArrayList<NameValuePair>();
		data.add(new BasicNameValuePair("password", pass));
		data.add(new BasicNameValuePair("email", email));
		data.add(new BasicNameValuePair("gcm_reg", GCMRegistrar
				.getRegistrationId(mContext)));
		data.add(new BasicNameValuePair("os", String.valueOf(1)));
		mMail = email;
		mPass = pass;
		fetch(data);
	}
}
