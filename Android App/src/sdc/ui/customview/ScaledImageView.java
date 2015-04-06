package sdc.ui.customview;

import sdc.travelapp.R;
import android.content.Context;
import android.content.res.TypedArray;
import android.util.AttributeSet;
import android.widget.ImageView;

public class ScaledImageView extends ImageView {
	private boolean isScaleWidth = true;
	private float widthScale;
	private float heightScale;

	public ScaledImageView(Context context) {
		super(context);
	}

	public ScaledImageView(Context context, AttributeSet attrs) {
		this(context, attrs, 0);
	}

	public ScaledImageView(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
		TypedArray a = context.obtainStyledAttributes(attrs,
				R.styleable.ScaledImageView, defStyle, 0);
		int scaleType = a.getInt(R.styleable.ScaledImageView_sizeScaleType, 0);
		if (scaleType == 0) {
			isScaleWidth = true;
		} else {
			isScaleWidth = false;
		}
		widthScale = a.getFloat(R.styleable.ScaledImageView_scaleWidth, 1);
		heightScale = a.getFloat(R.styleable.ScaledImageView_scaleHeight, 1);
		a.recycle();
	}

	@Override
	protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
		super.onMeasure(widthMeasureSpec, heightMeasureSpec);
		float width = getMeasuredWidth();
		float height = getMeasuredHeight();
		if (isScaleWidth) {
			height = width * heightScale * 1.0f / widthScale;
		} else {
			width = height * widthScale * 1.0f / heightScale;
		}

		setMeasuredDimension((int) width, (int) height);
	}

	public void setScale(float widthScale, float heightScale) {
		this.widthScale = widthScale;
		this.heightScale = heightScale;
		invalidate();
	}

	public void setScaleType(boolean isScaleWidth) {
		this.isScaleWidth = false;
		invalidate();
	}
}
