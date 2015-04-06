package sdc.net.webservice;

import java.io.File;

import org.json.JSONObject;


import sdc.application.TravelPrefs;
import sdc.net.utils.MultipartUtility;
import sdc.travelapp.R;
import sdc.ui.travelapp.MainActivity;
import android.os.AsyncTask;
import android.text.TextUtils;

public class EditAccountWS {
	private EditAccountTask mTask;

	public EditAccountWS() {
	}

	public void fetchData(MainActivity context, String pass, String newpass,
			String username, String userid, String avatarurl) {
		if (mTask != null) {
			mTask.cancel(true);
		}
		mTask = new EditAccountTask(context);
		mTask.execute(pass, newpass, username, userid, avatarurl);
	}

	private class EditAccountTask extends AsyncTask<String, String, String> {
		MainActivity mContext;

		public EditAccountTask(MainActivity context) {
			mContext = context;
		}

		@Override
		protected void onPreExecute() {
			mContext.showProgressDialog(
					mContext.getString(R.string.tv_edit_acc),
					mContext.getString(R.string.wait_in_sec), null);
		}

		@Override
		protected String doInBackground(String... params) {
			try {
				MultipartUtility utility = new MultipartUtility(
						BaseWS.getEquivalentURL(BaseWS.EDIT_ACC), "UTF-8");
				utility.addFormField("password", params[0]);
				utility.addFormField("new_password", params[1]);
				utility.addFormField("username", params[2]);
				utility.addFormField("userid", params[3]);
				if (!TextUtils.isEmpty(params[4])) {
					File file = new File(params[4]);
					if (file.exists()) {
						utility.addFilePart("avatarurl", file);
					}
				}
				String response = utility.connect();
				JSONObject data = new JSONObject(response);
				if (data.getInt("success") == 1) {
					String newName = data.getString("username");
					String newAvatar = data.getString("avatarurl");
					publishProgress(params[1], params[2], newName, newAvatar,
							params[4]);
					return data.getString("message");
				} else {
					return data.getString("message");
				}
			} catch (Exception e) {
				e.printStackTrace();
			}
			return null;
		}

		@Override
		protected void onProgressUpdate(String... values) {
			if (!TextUtils.isEmpty(values[0]))
				TravelPrefs.putData(mContext, TravelPrefs.PREF_USER_PASS,
						values[0]);
			if (!TextUtils.isEmpty(values[1]))
				TravelPrefs.putData(mContext, TravelPrefs.PREF_USER_NAME,
						values[1]);
			TravelPrefs
					.putData(mContext, TravelPrefs.PREF_USER_NAME, values[2]);
			TravelPrefs.putData(mContext, TravelPrefs.PREF_USER_AVATAR,
					BaseWS.HOST + values[3]);
			// delete local avatar
			if (!TextUtils.isEmpty(values[4])) {
				File file = new File(values[4]);
				file.delete();
			}
		}

		@Override
		protected void onPostExecute(String result) {
			if (result != null) {
				mContext.dismissProgressDialog();
				mContext.showToast(result);
				mContext.reloadCurFragment();
			} else {
				mContext.dismissProgressDialog();
				mContext.showToast(mContext
						.getString(R.string.toast_problem_network));
			}
		}

	}
}
