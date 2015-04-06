package sdc.ui.utils;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.nio.channels.FileChannel;

import sdc.travelapp.R;
import android.annotation.SuppressLint;
import android.content.Context;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Matrix;
import android.os.Build;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup.LayoutParams;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

public class Utils {
	public static Bitmap loadBitmapFromView(View v) {
		if (v.getMeasuredHeight() <= 0) {
			v.measure(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
			Bitmap b = Bitmap.createBitmap(v.getMeasuredWidth(),
					v.getMeasuredHeight(), Bitmap.Config.RGB_565);
			Canvas c = new Canvas(b);
			v.layout(0, 0, v.getMeasuredWidth(), v.getMeasuredHeight());
			v.draw(c);
			return b;
		} else {
			Bitmap b = Bitmap.createBitmap(v.getWidth(), v.getHeight(),
					Bitmap.Config.RGB_565);
			Canvas c = new Canvas(b);
			v.layout(v.getLeft(), v.getTop(), v.getRight(), v.getBottom());
			v.draw(c);
			return b;
		}
	}

	@SuppressLint("InflateParams")
	public static Bitmap createSlideShowPhoto(Context context, String filePath,
			String description) {
		BitmapFactory.Options options = new BitmapFactory.Options();
		options.inJustDecodeBounds = true;
		BitmapFactory.decodeFile(filePath, options);
		int imageHeight = options.outHeight;
		int imageWidth = options.outWidth;

		int screenWidth = 800;
		int screenHeight = 800;

		View layout = LayoutInflater.from(context).inflate(R.layout.item_photo,
				null);
		ImageView imageView = (ImageView) layout.findViewById(R.id.img);
		TextView tvDescription = (TextView) layout
				.findViewById(R.id.tv_description);
		int sizeWith;
		int sizeHeight;
		if ((imageWidth * 1.0 / imageHeight) >= (screenWidth * 1.0 / screenHeight)) {
			sizeWith = screenWidth;
			sizeHeight = (int) (imageHeight * screenWidth * 1.0 / imageWidth);
		} else {
			sizeHeight = screenHeight;
			sizeWith = (int) (imageWidth * screenHeight * 1.0 / imageHeight);
		}
		FrameLayout layoutContent = (FrameLayout) layout
				.findViewById(R.id.layout_content);

		options.inSampleSize = calculateInSampleSize(options, sizeWith,
				sizeHeight);

		// Decode bitmap with inSampleSize set
		options.inJustDecodeBounds = false;
		Bitmap b = BitmapFactory.decodeFile(filePath, options);
		Bitmap fixedBitmap = rotateBitmap(filePath,
				Bitmap.createScaledBitmap(b, sizeWith, sizeHeight, true));
		sizeWith = fixedBitmap.getWidth();
		sizeHeight = fixedBitmap.getHeight();
		LinearLayout.LayoutParams layoutParams = (LinearLayout.LayoutParams) layoutContent
				.getLayoutParams();
		layoutParams.width = sizeWith;
		layoutParams.height = sizeHeight;
		layoutContent.setLayoutParams(layoutParams);

		imageView.setImageBitmap(fixedBitmap);
		b.recycle();
		tvDescription.setText(description);
		layout.measure(sizeWith, sizeHeight);
		b = Bitmap.createBitmap(layout.getMeasuredWidth(),
				layout.getMeasuredHeight(), Bitmap.Config.RGB_565);
		Canvas c = new Canvas(b);
		layout.layout(0, 0, layout.getMeasuredWidth(),
				layout.getMeasuredHeight());
		layout.draw(c);
		return b;
		// return loadBitmapFromView(layout);
	}

	public static int calculateInSampleSize(BitmapFactory.Options options,
			int reqWidth, int reqHeight) {
		// Raw height and width of image
		final int height = options.outHeight;
		final int width = options.outWidth;
		int inSampleSize = 1;

		if (height > reqHeight || width > reqWidth) {

			final int halfHeight = height / 2;
			final int halfWidth = width / 2;

			// Calculate the largest inSampleSize value that is a power of 2 and
			// keeps both
			// height and width larger than the requested height and width.
			while ((halfHeight / inSampleSize) > reqHeight
					&& (halfWidth / inSampleSize) > reqWidth) {
				inSampleSize *= 2;
			}
		}

		return inSampleSize;
	}

	public static Bitmap decodeSampledBitmapFromResource(Resources res,
			int resId, int reqWidth, int reqHeight) {

		// First decode with inJustDecodeBounds=true to check dimensions
		final BitmapFactory.Options options = new BitmapFactory.Options();
		options.inJustDecodeBounds = true;
		BitmapFactory.decodeResource(res, resId, options);

		// Calculate inSampleSize
		options.inSampleSize = calculateInSampleSize(options, reqWidth,
				reqHeight);

		// Decode bitmap with inSampleSize set
		options.inJustDecodeBounds = false;
		return BitmapFactory.decodeResource(res, resId, options);
	}

	public static Bitmap decodeSampledBitmapFromFile(String filePath,
			int reqWidth, int reqHeight) {

		// First decode with inJustDecodeBounds=true to check dimensions
		final BitmapFactory.Options options = new BitmapFactory.Options();
		options.inJustDecodeBounds = true;
		BitmapFactory.decodeFile(filePath, options);

		// Calculate inSampleSize
		options.inSampleSize = calculateInSampleSize(options, reqWidth,
				reqHeight);

		// Decode bitmap with inSampleSize set
		options.inJustDecodeBounds = false;

		Bitmap bitmap = BitmapFactory.decodeFile(filePath, options);
		return rotateBitmap(filePath, bitmap);
	}

	public static void copyFile(File sourceFile, File destFile)
			throws IOException {
		if (!destFile.exists()) {
			destFile.createNewFile();
		}

		FileChannel source = null;
		FileChannel destination = null;

		try {
			source = new FileInputStream(sourceFile).getChannel();
			destination = new FileOutputStream(destFile).getChannel();
			destination.transferFrom(source, 0, source.size());
		} finally {
			if (source != null) {
				source.close();
			}
			if (destination != null) {
				destination.close();
			}
		}
	}

	public static Bitmap rotateBitmap(String src, Bitmap bitmap) {
		try {
			int orientation = getExifOrientation(src);

			if (orientation == 1) {
				return bitmap;
			}
			int width = bitmap.getWidth();
			int height = bitmap.getHeight();
			int temp;

			Matrix matrix = new Matrix();
			switch (orientation) {
			case 2:
				matrix.setScale(-1, 1);
				break;
			case 3:
				matrix.setRotate(180);
				break;
			case 4:
				matrix.setRotate(180);
				matrix.postScale(-1, 1);
				break;
			case 5:
				matrix.setRotate(90);
				matrix.postScale(-1, 1);
				temp = width;
				width = height;
				height = temp;
				break;
			case 6:
				matrix.setRotate(90);
				temp = width;
				width = height;
				height = temp;
				break;
			case 7:
				matrix.setRotate(-90);
				temp = width;
				width = height;
				height = temp;
				matrix.postScale(-1, 1);
				break;
			case 8:
				matrix.setRotate(-90);
				temp = width;
				width = height;
				height = temp;
				break;
			default:
				return bitmap;
			}

			try {
				Bitmap oriented = Bitmap.createBitmap(bitmap, 0, 0,
						bitmap.getWidth(), bitmap.getHeight(), matrix, true);
				bitmap.recycle();
				return oriented;
			} catch (OutOfMemoryError e) {
				e.printStackTrace();
				return bitmap;
			}
		} catch (IOException e) {
			e.printStackTrace();
		}

		return bitmap;
	}

	private static int getExifOrientation(String src) throws IOException {
		int orientation = 1;

		try {
			/**
			 * if your are targeting only api level >= 5 ExifInterface exif =
			 * new ExifInterface(src); orientation =
			 * exif.getAttributeInt(ExifInterface.TAG_ORIENTATION, 1);
			 */
			if (Build.VERSION.SDK_INT >= 5) {
				Class<?> exifClass = Class
						.forName("android.media.ExifInterface");
				Constructor<?> exifConstructor = exifClass
						.getConstructor(new Class[] { String.class });
				Object exifInstance = exifConstructor
						.newInstance(new Object[] { src });
				Method getAttributeInt = exifClass.getMethod("getAttributeInt",
						new Class[] { String.class, int.class });
				Field tagOrientationField = exifClass
						.getField("TAG_ORIENTATION");
				String tagOrientation = (String) tagOrientationField.get(null);
				orientation = (Integer) getAttributeInt.invoke(exifInstance,
						new Object[] { tagOrientation, 1 });
			}
		} catch (ClassNotFoundException e) {
			e.printStackTrace();
		} catch (SecurityException e) {
			e.printStackTrace();
		} catch (NoSuchMethodException e) {
			e.printStackTrace();
		} catch (IllegalArgumentException e) {
			e.printStackTrace();
		} catch (InstantiationException e) {
			e.printStackTrace();
		} catch (IllegalAccessException e) {
			e.printStackTrace();
		} catch (InvocationTargetException e) {
			e.printStackTrace();
		} catch (NoSuchFieldException e) {
			e.printStackTrace();
		}

		return orientation;
	}
}
