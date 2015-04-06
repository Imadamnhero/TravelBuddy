package sdc.net.webservice;

import java.util.ArrayList;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.os.AsyncTask.Status;

import sdc.data.Note;
import sdc.net.listeners.IWebServiceListener;
import sdc.ui.utils.DateTimeUtils;

public class SyncNotesWS extends BaseSyncWS<List<Note>> {
	private static SyncNotesWS mInstance;

	public static SyncNotesWS getInstance() {
		if (mInstance == null) {
			mInstance = new SyncNotesWS();
		}
		return mInstance;
	}

	private SyncNotesWS() {
		super(null, BaseWS.SYNC_NOTE);
	}

	@Override
	public List<Note> parseData(String json) {
		try {
			JSONObject obj = new JSONObject(json);
			JSONArray arrNewNotes = obj.getJSONArray("updated_data");
			List<Note> result = new ArrayList<Note>();
			for (int i = 0; i < arrNewNotes.length(); i++) {
				JSONObject objNote = arrNewNotes.getJSONObject(i);
				int serverId = objNote.getInt("serverid");
				String title = objNote.getString("title");
				String content = objNote.getString("content");
				String time = objNote.getString("time");
				int ownerId = objNote.getInt("ownerid");
				int tripId = objNote.getInt("tripid");
				int flag = objNote.getInt("flag");
				result.add(new Note(-1, title, content, DateTimeUtils
						.parseServerDate(time), ownerId, serverId, tripId, flag));
			}
			return result;
		} catch (JSONException e) {
		}
		return null;
	}

	public boolean isLoading() {
		if (this.mJSONTask == null || this.mJSONTask.isCancelled()
				|| this.mJSONTask.getStatus() == Status.FINISHED) {
			return false;
		} else {
			return true;
		}
	}

	public void fetchData(IWebServiceListener listener, int curVer,
			JSONArray arrNote, int tripId) {
		this.mListener = listener;
		JSONObject obj = new JSONObject();
		try {
			obj.put("client_ver", curVer);
			obj.put("data", arrNote);
			obj.put("tripid", tripId);
			super.fetch(obj);
		} catch (JSONException e) {
			e.printStackTrace();
		}
	}

}
