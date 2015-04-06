package sdc.ui.customview;

import sdc.travelapp.R;
import android.app.Dialog;
import android.content.Context;
import android.os.Bundle;
import android.text.Html;
import android.view.Gravity;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.TextView;

public class CustomDialog extends Dialog {
	private String title, message;
	public OnClickLeft mOnClickLeft;
	public OnClickRight mOnClickRight;
	private Button myBtnLeft, myBtnRight;
	private TextView myTvTitle, myTvMessage;

	public CustomDialog(Context context, String title, String message) {
		super(context);
		this.title = title;
		this.message = message; 
	}

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		this.requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.custom_dialog);
		Window window = this.getWindow();
		WindowManager.LayoutParams wlp = window.getAttributes();
		wlp.gravity = Gravity.CENTER;
		wlp.width = WindowManager.LayoutParams.MATCH_PARENT;
		wlp.flags &= WindowManager.LayoutParams.FLAG_DIM_BEHIND;
		window.setAttributes(wlp);
		this.getWindow().setAttributes(wlp);
		setCancelable(false);
		init();
	}

	public void init() {
		myBtnLeft = (Button) findViewById(R.id.btn_left);
		myBtnRight = (Button) findViewById(R.id.btn_right);
		myTvTitle = (TextView) findViewById(R.id.tv_title);
		myTvMessage = (TextView) findViewById(R.id.tv_message);
		myTvTitle.setText(title);
		myTvMessage.setText(Html.fromHtml(message));
		myBtnLeft.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View v) {
				if (mOnClickLeft != null) {
					CustomDialog.this.dismiss();
					mOnClickLeft.click();
				}
			}
		});
		myBtnRight.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View v) {
				CustomDialog.this.dismiss();
				if (mOnClickRight != null) {
					CustomDialog.this.dismiss();
					mOnClickRight.click();
				}
			}
		});
	}

	public void setTextBtn(String btn1, String btn2) {
		myBtnLeft.setText(btn1);
		myBtnRight.setText(btn2);
	}

	public void setTitle(String title) {
		myTvTitle.setText(title);
	}

	public void setMessage(String message) {
		myTvMessage.setText(Html.fromHtml(message));
	}

	public void setTextBtnLeft(String text) {
		myBtnLeft.setText(text);
	}

	public void goneBtnRight() {
		myBtnRight.setVisibility(View.GONE);
	}

	public void setOnClickLeft(OnClickLeft onClickleft) {
		this.mOnClickLeft = onClickleft;
	}

	public void setOnClickRight(OnClickRight onClickRight) {
		this.mOnClickRight = onClickRight;
	}

	public void show() {
		super.show();
	}

	public static interface OnClickLeft {
		public void click();
	}

	public static interface OnClickRight {
		public void click();
	}

}
