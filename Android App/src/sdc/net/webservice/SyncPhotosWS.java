package sdc.net.webservice;

import java.io.File;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import sdc.application.TravelApplication;
import sdc.application.TravelPrefs;
import sdc.data.Photo;
import sdc.data.database.ContentProviderDB;
import sdc.data.database.adapter.PhotoTableAdapter;
import sdc.data.database.adapter.VersionTableAdapter;
import sdc.net.utils.MultipartUtility;
import android.annotation.SuppressLint;
import android.content.Context;
import android.content.Intent;
import android.os.AsyncTask;
import android.os.AsyncTask.Status;
import android.text.TextUtils;
import android.util.Pair;

public class SyncPhotosWS {
	public static final String TAG = "syncphoto";
	private static final Map<Integer, Pair<Photo, UploadCallBack>> sUploadingPhotos = new LinkedHashMap<Integer, Pair<Photo, UploadCallBack>>();
	public static final String FILTER_UPLOAD_PHOTO = "sdc.travelapp.UloadPhoto";
	private static SyncPhotoTask mTask;

	public static void doUpload(Context context, int userId, int tripId) {
		PhotoTableAdapter adapter = new PhotoTableAdapter(context);
		List<Photo> photos = adapter.getAll(tripId);
		for (Photo photo : photos) {
			if (photo.getServerId() <= 0
					|| photo.getFlag() != ContentProviderDB.FLAG_NONE) {
				if (TravelApplication.isOnline(context))
					fetchData(context, userId, photo, null);
			}
		}
		if (sUploadingPhotos.size() == 0) {
			fetchData(context, userId, null, null);
		}

	}

	@SuppressLint("NewApi")
	public static void fetchData(Context context, int userId, Photo photo,
			UploadCallBack callback) {
		if (TravelApplication.isOnline(context)) {
			if (photo != null) {
				if (sUploadingPhotos.get(photo.getId()) == null) {
					sUploadingPhotos.put(photo.getId(),
							new Pair<Photo, UploadCallBack>(photo, callback));
					if (mTask == null || mTask.isCancelled()
							|| mTask.getStatus() == Status.FINISHED) {
						mTask = new SyncPhotoTask(context, userId, photo,
								callback);
						mTask.execute();
					}
				}
			} else {
				if (sUploadingPhotos.get(0) == null) {
					sUploadingPhotos.put(0, new Pair<Photo, UploadCallBack>(
							photo, callback));
					if (mTask == null || mTask.isCancelled()
							|| mTask.getStatus() == Status.FINISHED) {
						mTask = new SyncPhotoTask(context, userId, photo,
								callback);
						mTask.execute();
					}
				}
			}
		}
	}

	static class SyncPhotoTask extends AsyncTask<Void, Void, String> {
		private UploadCallBack callback;
		private Context context;
		private int userId;
		private Photo photo;

		public SyncPhotoTask(Context context, int userId, Photo photo,
				UploadCallBack callback) {
			this.callback = callback;
			this.context = context;
			this.photo = photo;
			this.userId = userId;
		}

		@Override
		protected void onPreExecute() {
			super.onPreExecute();
		}

		@Override
		protected String doInBackground(Void... params) {
			try {
				MultipartUtility utility = new MultipartUtility(
						BaseWS.getEquivalentURL(BaseWS.SYNC_PHOTO), "UTF-8");
				utility.addFormField("client_ver",
						String.valueOf(getPhotoVersion(context)));
				if (photo != null) {
					utility.addFormField("flag",
							String.valueOf(photo.getFlag()));
					utility.addFormField("ownerid",
							String.valueOf(photo.getOwnerId()));
					utility.addFormField("isreceipt",
							String.valueOf(photo.isReceipt() ? 1 : 0));
					utility.addFormField("clientid",
							String.valueOf(photo.getId()));
					utility.addFormField("caption", photo.getCaption());
					utility.addFormField("serverid",
							String.valueOf(photo.getServerId()));
					if (!TextUtils.isEmpty(photo.getUrlImage())) {
						File file = new File(photo.getUrlImage());
						if (file.exists()) {
							utility.addFilePart("photourl", file);
						}
					}
				} else {
					utility.addFormField("ownerid", String.valueOf(userId));
					utility.addFormField("flag", "0");
				}
				// addIdUploading(idUploading);
				String response = utility.connect();
				return response;
			} catch (Exception e) {
				e.printStackTrace();
			} catch (OutOfMemoryError e) {
				e.printStackTrace();
			}
			return null;
		}

		@Override
		protected void onPostExecute(String result) {
			if (photo != null) {
				sUploadingPhotos.remove(photo.getId());
			} else {
				sUploadingPhotos.remove(0);
			}

			if (result == null && callback != null) {
				callback.onFail(photo,
						"Upload fail. Please check network connection!");
			} else if (result != null) {
				try {
					JSONObject obj = new JSONObject(result);
					int success = obj.getInt("success");
					if (success == 1) {

						// parse data in this json
						int newVersion = obj.getInt("new_ver");
						JSONObject commitedObj = obj
								.getJSONObject("committed_id");
						JSONArray updatedData = obj
								.getJSONArray("updated_data");

						// handle that parsed data
						new VersionTableAdapter(context).setVersionTableOfUser(
								ContentProviderDB.COL_VERSION_PHOTO,
								newVersion, (Integer) TravelPrefs.getData(
										context, TravelPrefs.PREF_USER_ID));
						Pair<Integer, String> s = handleCommittedData(context,
								photo, commitedObj);

						handleUpdatedData(context, updatedData);
						if (callback != null) {
							callback.onSuccess(photo);
						}
						if (photo != null) {
							if (s != null) {
								if (photo.getServerId() <= 0)
									photo.setServerId(s.first);
								photo.setUrlImage(s.second);
							}
							Intent intent = new Intent(FILTER_UPLOAD_PHOTO);
							intent.putExtra("photo", photo);
							intent.putExtra("success", true);
							context.sendBroadcast(intent);
						}

					} else {
						if (photo != null) {
							if (callback != null) {
								callback.onFail(photo, obj.getString("message"));
							}
							Intent intent = new Intent(FILTER_UPLOAD_PHOTO);
							intent.putExtra("photo", photo);
							intent.putExtra("success", false);
							intent.putExtra("message", obj.getString("message"));
							context.sendBroadcast(intent);
						}
					}
				} catch (JSONException e) {
					if (callback != null) {
						callback.onFail(photo, e.getMessage());
					}
					Intent intent = new Intent(FILTER_UPLOAD_PHOTO);
					intent.putExtra("photo", photo);
					intent.putExtra("success", false);
					intent.putExtra("message", e.getMessage());
					context.sendBroadcast(intent);
				}
			} else {
				if (callback != null) {
					callback.onFail(photo, "Uncaught problem");
				}
				if (photo != null) {
					Intent intent = new Intent(FILTER_UPLOAD_PHOTO);
					intent.putExtra("photo", photo);
					intent.putExtra("success", false);
					intent.putExtra("message", "Uncaught problem");
					context.sendBroadcast(intent);
				}
			}
			if (sUploadingPhotos.size() > 0) {
				for (Integer key : sUploadingPhotos.keySet()) {
					mTask = new SyncPhotoTask(context, userId,
							sUploadingPhotos.get(key).first,
							sUploadingPhotos.get(key).second);
					mTask.execute();
					break;
				}
			}
		}

		@Override
		protected void onCancelled() {
			super.onCancelled();
			if (photo != null)
				sUploadingPhotos.remove(photo.getId());
			else
				sUploadingPhotos.remove(0);
		}

	}

	public interface UploadCallBack {
		public void onSuccess(Photo photo);

		public void onFail(Photo photo, String reason);
	}

	/**
	 * update severId and change url photo become a link instead local path
	 * 
	 * @param clientId
	 * @param serverId
	 * @param photoUrl
	 */
	private static Pair<Integer, String> handleCommittedData(Context context,
			Photo photo, JSONObject commitedObj) {
		try {
			int clientId = commitedObj.getInt("clientid");
			int serverId = commitedObj.getInt("serverid");
			String photoUrl = commitedObj.getString("photourl");
			new PhotoTableAdapter(context).doneUpdatingFromServer(photo,
					clientId, serverId, photoUrl);
			return new Pair<Integer, String>(serverId, photoUrl);
		} catch (JSONException e) {
			e.printStackTrace();
		} catch (Exception e) {
			// TODO: handle exception
		}
		return null;
	}

	/**
	 * insert a new row of photo from server
	 * 
	 * @param photo
	 */
	private static void handleUpdatedData(Context context,
			JSONArray updated_data) {
		try {
			for (int i = 0; i < updated_data.length(); i++) {
				JSONObject updateObj = updated_data.getJSONObject(i);
				int ownerId = updateObj.getInt("ownerid");
				int serverId = updateObj.getInt("serverid");
				boolean isReceipt = updateObj.getInt("isreceipt") == 1 ? true
						: false;
				String caption = updateObj.getString("caption");
				String photoUrl = updateObj.getString("photourl");
				int tripId = updateObj.getInt("tripid");
				int flag = updateObj.getInt("flag");
				if (flag == ContentProviderDB.FLAG_ADD
						|| flag == ContentProviderDB.FLAG_EDIT) {
					Photo photo = new Photo(-1, photoUrl, caption, ownerId,
							tripId, isReceipt, serverId, flag);
					new PhotoTableAdapter(context).insertOrUpdatePhoto(photo);
				} else if (flag == ContentProviderDB.FLAG_DEL) {
					new PhotoTableAdapter(context).deleteUponServerId(serverId);
				}
			}
		} catch (JSONException e) {
		}
	}

	public static boolean checkIdIsUploading(int id) {
		return sUploadingPhotos.get(id) != null;
	}

	public static int getPhotoVersion(Context context) {
		return new VersionTableAdapter(context).getVersionTableofUser(
				(Integer) TravelPrefs
						.getData(context, TravelPrefs.PREF_USER_ID),
				ContentProviderDB.COL_VERSION_PHOTO);
	}

}
