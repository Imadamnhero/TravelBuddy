package sdc.travelapp;

import android.os.Environment;

public class Configs {
	public static final String SDCARD_PATH = Environment
			.getExternalStorageDirectory().getPath();
	public static final String TRAVELBUDDY_PATH = SDCARD_PATH + "/TravelBuddy";
	public static final String TRAVEL_IMAGE_TMP_PATH = SDCARD_PATH
			+ "/TravelBuddy/tmpImages";
	public static final String TRAVEL_VIDEO_PATH = SDCARD_PATH
			+ "/TravelBuddy/videos";
}
