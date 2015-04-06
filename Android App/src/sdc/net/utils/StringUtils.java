package sdc.net.utils;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

import sdc.travelapp.R;

import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.os.Environment;
import android.util.Log;

public class StringUtils {

	public static String eliminateNumeral(String input) {
		StringBuilder builder = new StringBuilder(input);
		for (int i = 0; i < builder.length(); i++) {
			char check = builder.charAt(i);
			if ('0' <= check && '9' >= check) {
				builder.deleteCharAt(i);
				i--;
			}
		}
		return builder.toString();
	}

	public static String readAllFromInputStream(InputStream is) {
		BufferedReader br = null;
		StringBuilder sb = new StringBuilder();

		String line;
		try {
			br = new BufferedReader(new InputStreamReader(is));
			while ((line = br.readLine()) != null) {
				sb.append(line);
			}
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			if (br != null) {
				try {
					br.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}

		return sb.toString();
	}

	public static String getApplicationPath(Context context) {
		return Environment.getExternalStorageDirectory().getAbsolutePath()
				+ "/" + context.getString(R.string.app_name);
	}
}
