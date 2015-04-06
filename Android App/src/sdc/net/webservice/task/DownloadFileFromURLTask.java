package sdc.net.webservice.task;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

import sdc.net.utils.StringUtils;
import sdc.travelapp.R;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.os.AsyncTask;
import android.util.Log;
import android.widget.Toast;

public class DownloadFileFromURLTask extends AsyncTask<String, Integer, String> {
	public static final String TAG = "DownLoadFile";
	private Activity mContext;
	private File mDir;
	private File mFile;
	private ProgressDialog mDialog;

	public DownloadFileFromURLTask(Activity context) {
		mContext = context;
		mDir = new File(StringUtils.getApplicationPath(mContext)
				+ "/SlideShows");

		// + TravelPrefs.getData(context, TravelPrefs.PREF_USER_ID) + "/"
		// + TravelPrefs.getData(context, TravelPrefs.PREF_TRIP_ID)
		if (!mDir.exists()) {
			mDir.mkdirs();
		}
		mFile = new File(mDir,
				new SimpleDateFormat("'slideshow_'yyyyMMdd_HHmmss'.mp4'",
						Locale.ENGLISH).format(new Date()));
		mDialog = new ProgressDialog(mContext);
		mDialog.setMessage("Downloading SlideShow...");
		mDialog.setProgressStyle(ProgressDialog.STYLE_HORIZONTAL);
		mDialog.setMax(100);
		mDialog.setOnCancelListener(new DialogInterface.OnCancelListener() {

			@Override
			public void onCancel(DialogInterface dialog) {
				cancel(true);
			}
		});
	}

	@Override
	protected void onPreExecute() {
		super.onPreExecute();
		mDialog.show();
	}

	@SuppressLint("SimpleDateFormat")
	@Override
	protected String doInBackground(String... params) {
		try {
			Log.i(TAG, "image download beginning: " + params[0]);

			// Define InputStreams to read from the URLConnection.
			// uses 3KB download buffer
			saveUrl(mFile.getAbsolutePath(), params[0]);
			return mFile.getAbsolutePath();

		} catch (IOException e) {
			e.printStackTrace();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}

	@Override
	protected void onProgressUpdate(Integer... values) {
		super.onProgressUpdate(values);
		mDialog.setProgress(values[0]);
	}

	@Override
	protected void onPostExecute(String result) {
		super.onPostExecute(result);
		mDialog.dismiss();
		if (result != null) {
			Toast.makeText(
					mContext,
					mContext.getString(R.string.toast_download_success, result),
					Toast.LENGTH_LONG).show();
			onSuccess(result);
		} else {
			Toast.makeText(mContext,
					mContext.getString(R.string.toast_download_fail),
					Toast.LENGTH_LONG).show();
			if (mFile.exists()) {
				mFile.delete();
			}
		}
	}
	public void onSuccess(String filePath){
		
	}

	@Override
	protected void onCancelled() {
		super.onCancelled();
		if (mFile.exists()) {
			mFile.delete();
		}
	}

	public void saveUrl(final String filename, final String urlString)
			throws MalformedURLException, IOException {
		BufferedInputStream in = null;
		FileOutputStream fout = null;
		try {
			URL url = new URL(urlString);
			HttpURLConnection conn = null;
			conn = (HttpURLConnection) url.openConnection();
			long fileLength = conn.getContentLength();
			conn.disconnect();

			in = new BufferedInputStream(new URL(urlString).openStream());
			fout = new FileOutputStream(filename);

			final byte data[] = new byte[1024];
			int count;
			long readCount = 0;
			while ((count = in.read(data, 0, 1024)) != -1) {
				readCount += count;
				fout.write(data, 0, count);
				publishProgress((int) (readCount * 100.0 / fileLength));
			}
		} finally {
			if (in != null) {
				in.close();
			}
			if (fout != null) {
				fout.close();
			}
		}
	}

	public static void copyFile(final String source, final String destination)
			throws IOException {
		BufferedInputStream in = null;
		FileOutputStream fout = null;
		try {
			in = new BufferedInputStream(new FileInputStream(new File(source)));
			fout = new FileOutputStream(destination);

			final byte data[] = new byte[1024];
			int count;
			while ((count = in.read(data, 0, 1024)) != -1) {
				fout.write(data, 0, count);
			}
		} finally {
			if (in != null) {
				in.close();
			}
			if (fout != null) {
				fout.close();
			}
		}
	}
}
