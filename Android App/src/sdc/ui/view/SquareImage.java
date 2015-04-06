package sdc.ui.view;

import android.content.Context;
import android.util.AttributeSet;
import android.widget.ImageView;

public class SquareImage extends ImageView {

	public SquareImage(Context context) {
		super(context);
	}

	public SquareImage(Context context, AttributeSet attrs) {
		super(context, attrs);

	}

	public SquareImage(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
	}

	@Override
	protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
		super.onMeasure(widthMeasureSpec, heightMeasureSpec);
		int h = this.getMeasuredHeight();
		int w = this.getMeasuredWidth();
		// int squareDim = Math.min(w, h);
		int squareDim = w;
		setMeasuredDimension(squareDim, squareDim);
	}

}
