package sdc.ui.utils;

import java.io.ByteArrayOutputStream;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Bitmap.Config;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.util.Base64;
import android.util.DisplayMetrics;

public class GraphicUtils {
	public static int convertDpToPixel(Context context, float dp) {
		DisplayMetrics metrics = context.getResources().getDisplayMetrics();
		float px = dp * (metrics.densityDpi / 160f);
		return (int) px;
	}

	public static Bitmap StringToBitMap(String encodedString) {
		try {
			byte[] encodeByte = Base64.decode(encodedString, Base64.DEFAULT);
			Bitmap bitmap = BitmapFactory.decodeByteArray(encodeByte, 0,
					encodeByte.length);
			return bitmap;
		} catch (Exception e) {
			e.getMessage();
			return null;
		}
	}

	public static Bitmap drawableToBitmap(Drawable drawable) {
		if (drawable instanceof BitmapDrawable) {
			return ((BitmapDrawable) drawable).getBitmap();
		}

		Bitmap bitmap = Bitmap.createBitmap(drawable.getIntrinsicWidth(),
				drawable.getIntrinsicHeight(), Config.ARGB_8888);
		Canvas canvas = new Canvas(bitmap);
		drawable.setBounds(0, 0, canvas.getWidth(), canvas.getHeight());
		drawable.draw(canvas);

		return bitmap;
	}

	public static String BitMapToString(Bitmap bitmap) {
		ByteArrayOutputStream ByteStream = new ByteArrayOutputStream();
		bitmap.compress(Bitmap.CompressFormat.JPEG, 100, ByteStream);
		byte[] b = ByteStream.toByteArray();
		String temp = Base64.encodeToString(b, Base64.DEFAULT);
		return temp;
	}
	
	public static Bitmap cropBitmap(Context context, Bitmap source) {
		int bWidth = source.getWidth();
		int bHeight = source.getHeight();
		int size = Math.min(bWidth, bHeight);
		int width, height;
		if (android.os.Build.VERSION.SDK_INT >= 11) {
			height = (int) context.getResources().getDimension(
					android.R.dimen.notification_large_icon_height);
			width = (int) context.getResources().getDimension(
					android.R.dimen.notification_large_icon_width);
		} else {
			width = (int) GraphicUtils.convertDpToPixel(context, 50);
			height = width;
		}
		if (size == bWidth) {
			return Bitmap.createScaledBitmap(Bitmap.createBitmap(source, 0,
					(bHeight - size) / 2, size, size), width, height, true);
		} else {
			return Bitmap.createScaledBitmap(Bitmap.createBitmap(source,
					(bWidth - size) / 2, 0, size, size), width, height, true);
		}
	}

}
