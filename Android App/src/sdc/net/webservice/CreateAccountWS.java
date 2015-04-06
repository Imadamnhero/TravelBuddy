package sdc.net.webservice;

import java.io.File;

import org.json.JSONException;
import org.json.JSONObject;

import sdc.application.TravelPrefs;
import sdc.net.utils.MultipartUtility;
import sdc.travelapp.R;
import sdc.ui.travelapp.MainActivity;
import android.os.AsyncTask;
import android.text.TextUtils;

public class CreateAccountWS {
	private CreateAccTask mTask;

	public CreateAccountWS() {
	}

	public void fetchData(MainActivity context, String name, String email,
			String password, String avatar) {
		if (mTask != null) {
			mTask.cancel(true);
		}
		mTask = new CreateAccTask(context);
		mTask.execute(name, email, password, avatar);
	}

	private class CreateAccTask extends AsyncTask<String, Integer, JSONObject> {
		MainActivity mContext;
		String mMail;
		String mPass;

		public CreateAccTask(MainActivity context) {
			mContext = context;
		}

		@Override
		protected void onPreExecute() {
			mContext.showProgressDialog(
					mContext.getString(R.string.tv_create_acc),
					mContext.getString(R.string.wait_in_sec), null);
		}

		@Override
		protected JSONObject doInBackground(String... params) {
			try {
				mMail = params[1];
				mPass = params[2];
				MultipartUtility utility = new MultipartUtility(
						BaseWS.getEquivalentURL(BaseWS.CREATE_USER), "UTF-8");
				utility.addFormField("username", params[0]);
				utility.addFormField("email", params[1]);
				utility.addFormField("password", params[2]);
				if (!TextUtils.isEmpty(params[3])) {
					File file = new File(params[3]);
					if (file.exists()) {
						utility.addFilePart("avatarurl", file);
					}
				}
				String response = utility.connect();
				JSONObject data = new JSONObject(response);
				return data;
			} catch (Exception e) {
				e.printStackTrace();
			}
			return null;
		}

		@Override
		protected void onPostExecute(JSONObject jsonObj) {
			try {
				if (jsonObj == null) {
					mContext.dismissProgressDialog();
					mContext.showToast(mContext
							.getString(R.string.toast_problem_network));
				} else if (jsonObj.getInt("success") == 1) {
					mContext.dismissProgressDialog();
					mContext.showToast(jsonObj.getString("message"));
					new LoginWS(mContext, mContext).fetchData(mMail, mPass);
					TravelPrefs.putData(mContext, TravelPrefs.PREF_USER_MAIL,
							mMail);
					TravelPrefs.putData(mContext, TravelPrefs.PREF_USER_PASS,
							mPass);
					mContext.showProgressDialog(
							mContext.getString(R.string.tv_login),
							mContext.getString(R.string.wait_in_sec), null);
				} else {
					mContext.dismissProgressDialog();
					mContext.showToast(jsonObj.getString("message"));
				}
			} catch (JSONException e) {
				e.printStackTrace();
			}
		}
	}
}
