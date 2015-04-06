package sdc.application;

import java.io.File;

import android.annotation.SuppressLint;
import android.app.Application;
import android.content.Context;
import android.graphics.Bitmap.CompressFormat;
import android.graphics.Point;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.Build;
import android.view.Display;
import android.view.WindowManager;

import com.nostra13.universalimageloader.cache.disc.impl.UnlimitedDiscCache;
import com.nostra13.universalimageloader.cache.disc.naming.HashCodeFileNameGenerator;
import com.nostra13.universalimageloader.cache.memory.impl.LruMemoryCache;
import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.ImageLoaderConfiguration;
import com.nostra13.universalimageloader.core.assist.QueueProcessingType;
import com.nostra13.universalimageloader.core.download.BaseImageDownloader;
import com.nostra13.universalimageloader.utils.StorageUtils;

@SuppressLint("NewApi")
public class TravelApplication extends Application {
	public static int SCREEN_WIDTH = 0;
	public static int SCREEN_HEIGHT = 0;
	private boolean isTripAdded = false;
	private boolean isTripLogin = false;
	private boolean autoLogin = false;

	@Override
	public void onCreate() {
		super.onCreate();
		initImageLoader();
		getScreenSize();
		initStateApp();
	}

	private void initStateApp() {
		isTripAdded = (Integer) TravelPrefs.getData(getApplicationContext(),
				TravelPrefs.PREF_TRIP_ID) > 0 ? true : false;
		int userId = (Integer) TravelPrefs.getData(getApplicationContext(),
				TravelPrefs.PREF_USER_ID);
		isTripLogin = !isOnline() && userId != -1;
		if (isOnline())
			autoLogin = true;
	}

	private void initImageLoader() {
		File cacheDir = StorageUtils.getCacheDirectory(getApplicationContext(), true);
		ImageLoaderConfiguration config = new ImageLoaderConfiguration.Builder(
				getApplicationContext())
				.discCacheExtraOptions(480, 800, CompressFormat.JPEG, 100, null)
				.threadPoolSize(3)
				.threadPriority(Thread.NORM_PRIORITY - 1)
				.denyCacheImageMultipleSizesInMemory()
				.memoryCache(new LruMemoryCache(2 * 1024 * 1024))
				.memoryCacheSize(2 * 1024 * 1024)
				.discCache(new UnlimitedDiscCache(cacheDir))
				.discCacheSize(50 * 1024 * 1024)
				.memoryCacheSizePercentage(13)
				.discCacheFileCount(1000)
				.discCacheFileNameGenerator(new HashCodeFileNameGenerator())
				.imageDownloader(
						new BaseImageDownloader(getApplicationContext())) // default
				.tasksProcessingOrder(QueueProcessingType.FIFO) // default
				.defaultDisplayImageOptions(DisplayImageOptions.createSimple()) // default
				.build();
		ImageLoader.getInstance().init(config);
	}

	@Override
	public void onLowMemory() {
		ImageLoader.getInstance().clearMemoryCache();
		super.onLowMemory();
	}

	public boolean isTripAdded() {
		return isTripAdded;
	}

	public void setTripAdded(boolean isTripAdded) {
		this.isTripAdded = isTripAdded;
	}

	public boolean isTripLogin() {
		return isTripLogin;
	}

	public void setTripLogin(boolean isTripLogin) {
		this.isTripLogin = isTripLogin;
	}

	@SuppressWarnings("deprecation")
	private void getScreenSize() {
		WindowManager windowManager = (WindowManager) getApplicationContext()
				.getSystemService(Context.WINDOW_SERVICE);
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB_MR2) {
			Point size = new Point();
			windowManager.getDefaultDisplay().getSize(size);
			SCREEN_WIDTH = size.x;
			SCREEN_HEIGHT = size.y;
		} else {
			Display d = windowManager.getDefaultDisplay();
			SCREEN_WIDTH = d.getWidth();
			SCREEN_HEIGHT = d.getHeight();
		}
	}

	public boolean isOnline() {
		ConnectivityManager cm = (ConnectivityManager) getApplicationContext()
				.getSystemService(Context.CONNECTIVITY_SERVICE);
		NetworkInfo netInfo = cm.getActiveNetworkInfo();
		if (netInfo != null && netInfo.isConnectedOrConnecting()) {
			return true;
		}
		return false;
	}

	public static boolean isOnline(Context context) {
		ConnectivityManager cm = (ConnectivityManager) context
				.getSystemService(Context.CONNECTIVITY_SERVICE);
		NetworkInfo netInfo = cm.getActiveNetworkInfo();
		if (netInfo != null && netInfo.isConnectedOrConnecting()) {
			return true;
		}
		return false;
	}

	public boolean isAutoLogin() {
		return autoLogin;
	}

	public void setAutoLogin(boolean autoLogin) {
		this.autoLogin = autoLogin;
	}

}
