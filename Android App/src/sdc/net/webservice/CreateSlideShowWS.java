package sdc.net.webservice;

import java.io.File;

import org.json.JSONException;
import org.json.JSONObject;

import sdc.net.utils.MultipartUtility;
import sdc.travelapp.R;
import sdc.ui.fragment.CreateSlideShowFragment;
import sdc.ui.travelapp.MainActivity;
import android.content.Intent;
import android.net.Uri;
import android.os.AsyncTask;
import android.text.TextUtils;

public class CreateSlideShowWS {
	private CreateVideoTask mTask;
	private MainActivity mContext;
	private CreateSlideShowFragment mCallBack;

	public CreateSlideShowWS(MainActivity context,
			CreateSlideShowFragment callback) {
		mContext = context;
		mCallBack = callback;
	}

	/**
	 * 
	 * @param listImage
	 *            Be sure this param have format: 65,36,23,43 ...
	 * @param pathAudio
	 *            Optional, can be null or a path in local memory
	 */
	public void fetchData(int userId, int tripId, String listImage,
			String pathAudio) {
		if (mTask != null) {
			mTask.cancel(true);
		}
		mTask = new CreateVideoTask(mContext);
		mTask.execute(String.valueOf(userId), String.valueOf(tripId),
				listImage, pathAudio);
	}

	private class CreateVideoTask extends
			AsyncTask<String, Integer, JSONObject> {
		MainActivity mContext;

		public CreateVideoTask(MainActivity context) {
			mContext = context;
		}

		@Override
		protected void onPreExecute() {
			mContext.showProgressDialog(
					mContext.getString(R.string.tv_create_slideshow),
					mContext.getString(R.string.wait_in_sec), null);
		}

		@Override
		protected JSONObject doInBackground(String... params) {
			try {
				MultipartUtility utility = new MultipartUtility(
						BaseWS.getEquivalentURL(BaseWS.CREATE_SLIDESHOW),
						"UTF-8");
				utility.addFormField("user_id", params[0]);
				utility.addFormField("trip_id", params[1]);
				utility.addFormField("image_ids", params[2]);
				if (!TextUtils.isEmpty(params[3])) {
					File file = new File(params[3]);
					if (file.exists()) {
						utility.addFilePart("audio", file);
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
				} else if (jsonObj.getString("result").equals("success")) {
					mContext.dismissProgressDialog();
					String url = BaseWS.HOST_URL + jsonObj.getString("path");
					mCallBack.setVideoURl(url);
				} else if (jsonObj.getString("result").equals("fail")) {
					mContext.dismissProgressDialog();
					mContext.showToast(jsonObj.getString("message"));
				} else {
					mContext.showToast(mContext
							.getString(R.string.toast_uncaught_prob));
				}
			} catch (JSONException e) {
				e.printStackTrace();
			}
		}
	}
}
