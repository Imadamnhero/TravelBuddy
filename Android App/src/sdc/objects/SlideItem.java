package sdc.objects;

import android.graphics.Bitmap;

public class SlideItem {
	Bitmap bitmap;
	String description;

	public Bitmap getBitmap() {
		return bitmap;
	}

	public void setBitmap(Bitmap bitmap) {
		this.bitmap = bitmap;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public SlideItem(Bitmap bitmap, String description) {
		super();
		this.bitmap = bitmap;
		this.description = description;
	}

}
