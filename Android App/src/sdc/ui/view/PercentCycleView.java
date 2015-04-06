package sdc.ui.view;

import sdc.travelapp.R;
import sdc.ui.utils.GraphicUtils;
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Paint.Align;
import android.graphics.Paint.Style;
import android.graphics.RectF;
import android.graphics.Typeface;
import android.util.AttributeSet;
import android.view.View;

public class PercentCycleView extends View {
	private Paint mPaint;
	private RectF mRectf;
	private int mSize;
	private int lightGray, green, gray, white;
	private int mPercent = 50;
	private int mWidthProgress = 5; // in dp
	private int mFontSize = 15; // in dp

	public PercentCycleView(Context context) {
		super(context);
		initPaint();
	}

	public PercentCycleView(Context context, AttributeSet attrs) {
		super(context, attrs);
		initPaint();
	}

	public PercentCycleView(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
		initPaint();
	}

	@Override
	protected void onDraw(Canvas canvas) {
		mPaint.setColor(lightGray);
		canvas.drawCircle(mSize >> 1, mSize >> 1, mSize >> 1, mPaint);
		mPaint.setColor(green);
		canvas.drawArc(mRectf, -90F, (3.6F * (float) mPercent), true, mPaint);
		mPaint.setColor(white);
		canvas.drawCircle(
				mSize >> 1,
				mSize >> 1,
				(mSize >> 1)
						- GraphicUtils.convertDpToPixel(getContext(),
								mWidthProgress), mPaint);
		mPaint.setColor(gray);
		canvas.drawText(
				mPercent + "%",
				mSize >> 1,
				(mSize >> 1)
						+ GraphicUtils.convertDpToPixel(getContext(),
								mWidthProgress), mPaint);
	}

	@Override
	protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
		super.onMeasure(widthMeasureSpec, heightMeasureSpec);
		int h = this.getMeasuredHeight();
		int w = this.getMeasuredWidth();
		int squareDim = Math.min(w, h);
		mSize = squareDim;
		if (mRectf == null)
			mRectf = new RectF(0, 0, mSize, mSize);
		setMeasuredDimension(squareDim, squareDim);
	}

	private void initPaint() {
		mPaint = new Paint();
		mPaint.setAntiAlias(true);
		mPaint.setDither(true);
		mPaint.setStyle(Style.FILL);
		mPaint.setTextSize(GraphicUtils.convertDpToPixel(getContext(),
				mFontSize));
		mPaint.setTextAlign(Align.CENTER);
		mPaint.setTypeface(Typeface.create(Typeface.DEFAULT, Typeface.BOLD));
		lightGray = getResources().getColor(R.color.bg_progress_circle);
		green = getResources().getColor(R.color.progress_circle);
		gray = getResources().getColor(R.color.text_gray_color);
		white = getResources().getColor(R.color.small_circle_inside);
	}

	public int getPercent() {
		return mPercent;
	}

	public void setPercent(int mPercent) {
		this.mPercent = mPercent;
		invalidate();
	}

	public int getmWidthProgress() {
		return mWidthProgress;
	}

	public void setmWidthProgress(int mWidthProgress) {
		this.mWidthProgress = mWidthProgress;
		invalidate();
	}
}
