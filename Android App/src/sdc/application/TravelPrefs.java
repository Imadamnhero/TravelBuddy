package sdc.application;

import sdc.data.User;
import sdc.data.database.adapter.CategoryTableAdapter;
import android.content.Context;
import android.content.SharedPreferences;

public class TravelPrefs {
	public static final String PREF_USER_ID = "user_id";
	public static final String PREF_USER_PASS = "user_pass";
	public static final String PREF_USER_NAME = "user_name";
	public static final String PREF_USER_MAIL = "user_email";
	public static final String PREF_USER_AVATAR = "user_avatar";
	public static final String PREF_TRIP_ID = "trip_id";
	public static final String PREF_TRIP_NAME = "trip_name";
	public static final String PREF_FIRSTTIME_LOAD = "firsttime_load";
	public static final String PREF_REMEMBER = "remember_pass";
	public static final String PREF_GROUP_PHOTO = "group_photo";
	public static final String PREF_IS_ADDED_BUGET = "is_added_buget";
	public static final String SHARED_PREF_FILE = "sdc.application.travelapp";

	public synchronized static <T> boolean putData(Context context, String key,
			T data) {
		SharedPreferences prefs = context.getSharedPreferences(
				SHARED_PREF_FILE, Context.MODE_PRIVATE);
		SharedPreferences.Editor editor = prefs.edit();
		if (data instanceof String) {
			editor.putString(key, (String) data);
		} else if (data instanceof Boolean) {
			editor.putBoolean(key, (Boolean) data);
		} else if (data instanceof Float) {
			editor.putFloat(key, (Float) data);
		} else if (data instanceof Integer) {
			editor.putInt(key, (Integer) data);
		} else if (data instanceof Long) {
			editor.putLong(key, (Long) data);
		} else {
			return false;
		}
		editor.commit();
		return true;
	}

	public synchronized static Object getData(Context context, String key) {
		SharedPreferences prefs = context.getSharedPreferences(
				SHARED_PREF_FILE, Context.MODE_PRIVATE);
		if (key == PREF_TRIP_ID) {
			return prefs.getInt(key, -1);
		} else if (key == PREF_USER_AVATAR) {
			return prefs.getString(key, "");
		} else if (key == PREF_USER_ID) {
			return prefs.getInt(key, -1);
		} else if (key == PREF_USER_MAIL) {
			return prefs.getString(key, "");
		} else if (key == PREF_USER_NAME) {
			return prefs.getString(key, "");
		} else if (key == PREF_USER_PASS) {
			return prefs.getString(key, "");
		} else if (key == PREF_TRIP_NAME) {
			return prefs.getString(key, "");
		} else if (key == PREF_FIRSTTIME_LOAD) {
			return prefs.getBoolean(key, true);
		} else if (key == PREF_REMEMBER) {
			return prefs.getBoolean(key, true);
		} else if (key == PREF_GROUP_PHOTO) {
			return prefs.getInt(key, 0);
		} else if (key == PREF_IS_ADDED_BUGET) {
			return prefs.getBoolean(key, true);
		} else {
			return null;
		}
	}

	public synchronized static void putLoginData(Context context, User loginInfo) {
		SharedPreferences prefs = context.getSharedPreferences(
				SHARED_PREF_FILE, Context.MODE_PRIVATE);
		SharedPreferences.Editor editor = prefs.edit();
		editor.putInt(TravelPrefs.PREF_USER_ID, loginInfo.getId());
		editor.putString(TravelPrefs.PREF_USER_AVATAR, loginInfo.getAvatar());
		editor.putString(TravelPrefs.PREF_USER_NAME, loginInfo.getName());
		editor.putInt(TravelPrefs.PREF_TRIP_ID, loginInfo.getTripId());
		editor.putString(TravelPrefs.PREF_TRIP_NAME, loginInfo.getTripName());
		editor.commit();
	}

	public synchronized static void logOut(Context context) {
		SharedPreferences prefs = context.getSharedPreferences(
				SHARED_PREF_FILE, Context.MODE_PRIVATE);
		SharedPreferences.Editor editor = prefs.edit();
		editor.putInt(TravelPrefs.PREF_USER_ID, 0);
		editor.putString(TravelPrefs.PREF_USER_PASS, "");
		editor.putString(TravelPrefs.PREF_USER_AVATAR, "");
		editor.putString(TravelPrefs.PREF_USER_NAME, "");
		editor.putInt(TravelPrefs.PREF_TRIP_ID, -1);
		editor.putString(TravelPrefs.PREF_TRIP_NAME, "");
		editor.commit();
		try {
			new CategoryTableAdapter(context).clearTable();
		} catch (StackOverflowError e) {

		}

	}

	public synchronized static void clearData(Context context) {
		SharedPreferences prefs = context.getSharedPreferences(
				SHARED_PREF_FILE, Context.MODE_PRIVATE);
		SharedPreferences.Editor editor = prefs.edit();
		editor.putInt(TravelPrefs.PREF_TRIP_ID, -1);
		editor.putString(TravelPrefs.PREF_TRIP_NAME, "");
		editor.commit();
	}

}
