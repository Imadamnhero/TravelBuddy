package sdc.travelapp;

import sdc.application.TravelPrefs;
import sdc.net.listeners.IWebServiceListener;
import sdc.net.webservice.RegisterGcmWS;
import sdc.net.webservice.RemoveGcmWS;
import android.content.Context;
import android.text.TextUtils;
import android.util.Log;

import com.google.android.gcm.GCMRegistrar;

public class GCMUtils {
	public static final String TAG = "GCM";
	public static final String GCM_SENDER_ID = "482756534491";

	/**
	 * Register this account/device pair within the server.
	 * 
	 */
	public static void register(final Context context, final String regId,
			IWebServiceListener listener) {
		int userId = (Integer) TravelPrefs.getData(context,
				TravelPrefs.PREF_USER_ID);
		if (userId > 0)
			new RegisterGcmWS(listener).fetchData(userId, regId);
	}

	/**
	 * Unregister this account/device pair within the server.
	 */
	public static void unregister(final IWebServiceListener listener,
			final String regId) {
		Log.i(TAG, "unregistering device (regId = " + regId + ")");
		new RemoveGcmWS(listener).fetchData(regId);
	}

	public static String takeOrPostGcmId(Context context,
			final IWebServiceListener listener) {
		// Get GCM registration id
		final String regId = GCMRegistrar.getRegistrationId(context);

		// Check if regid already presents
		if (TextUtils.isEmpty(regId)) {
			// Registration is not present, register now with GCM
			GCMRegistrar.register(context, GCM_SENDER_ID);
		} else {
			final int userId = (Integer) TravelPrefs.getData(context,
					TravelPrefs.PREF_USER_ID);
			if (userId > 0)
				new RegisterGcmWS(listener).fetchData(userId, regId);
		}
		return null;
	}

	/**
	 * Issue a POST request to the server.
	 * 
	 * @param endpoint
	 *            POST address.
	 * @param params
	 *            request parameters.
	 * 
	 * @throws IOException
	 *             propagated from POST.
	 */
	// private static void post(String endpoint, Map<String, String> params)
	// throws IOException {
	//
	// URL url;
	// try {
	// url = new URL(endpoint);
	// } catch (MalformedURLException e) {
	// throw new IllegalArgumentException("invalid url: " + endpoint);
	// }
	// StringBuilder bodyBuilder = new StringBuilder();
	// Iterator<Entry<String, String>> iterator = params.entrySet().iterator();
	// // constructs the POST body using the parameters
	// while (iterator.hasNext()) {
	// Entry<String, String> param = iterator.next();
	// bodyBuilder.append(param.getKey()).append('=')
	// .append(param.getValue());
	// if (iterator.hasNext()) {
	// bodyBuilder.append('&');
	// }
	// }
	// String body = bodyBuilder.toString();
	// Log.v(TAG, "Posting '" + body + "' to " + url);
	// byte[] bytes = body.getBytes();
	// HttpURLConnection conn = null;
	// try {
	// Log.e("URL", "> " + url);
	// conn = (HttpURLConnection) url.openConnection();
	// conn.setDoOutput(true);
	// conn.setUseCaches(false);
	// conn.setFixedLengthStreamingMode(bytes.length);
	// conn.setRequestMethod("POST");
	// conn.setRequestProperty("Content-Type",
	// "application/x-www-form-urlencoded;charset=UTF-8");
	// // post the request
	// OutputStream out = conn.getOutputStream();
	// out.write(bytes);
	// out.close();
	// // handle the response
	// int status = conn.getResponseCode();
	// if (status != 200) {
	// throw new IOException("Post failed with error code " + status);
	// }
	// } finally {
	// if (conn != null) {
	// conn.disconnect();
	// }
	// }
	// }

}
