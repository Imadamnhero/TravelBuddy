package sdc.ui.view;

import java.util.ArrayList;
import java.util.List;

import sdc.application.TravelApplication;
import sdc.travelapp.R;
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Paint.Align;
import android.graphics.Paint.Style;
import android.graphics.RectF;
import android.graphics.Typeface;
import android.util.AttributeSet;
import android.view.View;

public class ChartPieView extends View {
	private List<Float> mListExpenses;
	private int white, yellow, white_trans;
	private List<Integer> mArrayColor;
	private int mSize;
	private int mWidthSeparate = 3;
	private RectF mRectf;
	private Paint mPaint;

	public ChartPieView(Context context) {
		super(context);
		initPaint();
	}

	public ChartPieView(Context context, AttributeSet attrs) {
		super(context, attrs);
		initPaint();
	}

	public ChartPieView(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
		initPaint();
	}

	@Override
	protected void onDraw(Canvas canvas) {
		if (mRectf == null) {
			mRectf = new RectF(0 + mWidthSeparate, 0 + mWidthSeparate, mSize
					- mWidthSeparate, mSize - mWidthSeparate);
		}
		float radius = mSize >> 1;
		if (mListExpenses != null && mListExpenses.size() > 0) {
			mPaint.setColor(white);
			canvas.drawCircle(radius, radius, radius, mPaint);
			float sum = sumExpenses(mListExpenses);
			float startAngle = 0;
			for (int i = 0; i < mListExpenses.size(); i++) {
				mPaint.setColor(mArrayColor.get(i % mArrayColor.size()));
				mPaint.setStrokeWidth(mWidthSeparate);
				float delta = (360F * mListExpenses.get(i) / sum);
				canvas.drawArc(mRectf, startAngle, delta, true, mPaint);
				mPaint.setColor(white);
				mPaint.setStrokeWidth(1);
				float pointX = (float) (radius + (radius- mWidthSeparate)
						* Math.cos(startAngle / 180 * Math.PI));
				float pointY = (float) (radius + (radius- mWidthSeparate)
						* Math.sin(startAngle / 180 * Math.PI));
				mPaint.setStrokeWidth(1);
				canvas.drawLine(radius, radius, pointX, pointY, mPaint);
				startAngle += delta;
			}
		} else {
			mPaint.setColor(white_trans);
			canvas.drawCircle(mSize >> 1, mSize >> 1, mSize >> 1, mPaint);
			mPaint.setColor(yellow);
			canvas.drawText("No Expenses Added", mSize >> 1, mSize >> 1, mPaint);
		}
	}

	@Override
	protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
		super.onMeasure(widthMeasureSpec, heightMeasureSpec);
		// int h = this.getMeasuredHeight();
		// int w = this.getMeasuredWidth();
		// int squareDim = Math.min(w, h);
		int squareDim = TravelApplication.SCREEN_WIDTH >> 1;
		mSize = squareDim;
		setMeasuredDimension(squareDim, squareDim);
	}

	private void initPaint() {
		mPaint = new Paint();
		mPaint.setAntiAlias(true);
		mPaint.setDither(true);
		mPaint.setStyle(Style.FILL);
		mPaint.setTextSize(20);
		mPaint.setTextAlign(Align.CENTER);
		mPaint.setTypeface(Typeface.create(Typeface.DEFAULT,
				Typeface.BOLD_ITALIC));
		//mPaint.setStrokeWidth(mWidthSeparate);
		// int[] colorId = Expense.COLOR;
		white_trans = getResources().getColor(R.color.pie_white_trans);
		white = getResources().getColor(R.color.pie_white);
		yellow = getResources().getColor(R.color.pie_yellow);
		mArrayColor = new ArrayList<Integer>();
	}

	private Float sumExpenses(List<Float> listMoney) {
		float sum = 0;
		for (Float float1 : listMoney) {
			sum += float1;
		}
		return sum;
	}

	public List<Float> getmListExpenses() {
		return mListExpenses;
	}

	public void setmListExpenses(List<Float> listExpenses, List<Integer> colors) {
		if (listExpenses != null) {
			this.mListExpenses = listExpenses;
			this.mArrayColor = colors;
			invalidate();
		}
	}
}
