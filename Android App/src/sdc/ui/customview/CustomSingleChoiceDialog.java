package sdc.ui.customview;

import sdc.travelapp.R;
import android.app.Dialog;
import android.content.Context;
import android.os.Bundle;
import android.view.Gravity;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.TextView;

public class CustomSingleChoiceDialog extends Dialog {
	private String title, checkbox1, checkbox2;
	private TextView tvCheckbox1, tvCheckbox2, myTvTitle;
	private View myLL1, myLL2;
	public OnClickLeft OnClickLeft;
	public OnClickRight OnClickRight;
	private TextView myBtnLeft;

	public CustomSingleChoiceDialog(Context context, String title,
			String item1, String item2) {
		super(context);
		this.title = title;
		this.checkbox1 = item1;
		this.checkbox2 = item2;
	}

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		this.requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.custom_picture_dialog);
		Window window = this.getWindow();
		WindowManager.LayoutParams wlp = window.getAttributes();
		wlp.gravity = Gravity.CENTER;
		wlp.width = WindowManager.LayoutParams.MATCH_PARENT;
		wlp.flags &= WindowManager.LayoutParams.FLAG_DIM_BEHIND;
		window.setAttributes(wlp);
		this.getWindow().setAttributes(wlp);

		init();
	}

	public void init() {
		myBtnLeft = (TextView) findViewById(R.id.btn_left);
		tvCheckbox1 = (TextView) findViewById(R.id.tv_checkbox_1);
		tvCheckbox2 = (TextView) findViewById(R.id.tv_checkbox_2);
		myLL1 = findViewById(R.id.ll_checkbox_1);
		myLL2 = findViewById(R.id.ll_checkbox_2);
		myTvTitle = (TextView) findViewById(R.id.tv_title);
		myTvTitle.setText(title);
		tvCheckbox1.setText(checkbox1);
		tvCheckbox2.setText(checkbox2);
		myBtnLeft.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View v) {
				CustomSingleChoiceDialog.this.dismiss();
			}
		});
		myLL1.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				if (OnClickLeft != null) {
					OnClickLeft.Click();
				}
			}
		});
		myLL2.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				if (OnClickRight != null) {
					OnClickRight.Click();
				}
			}
		});

	}

	public void setTextBtn(String btn1) {
		myBtnLeft.setText(btn1);
	}

	public void setTitle(String title) {
		myTvTitle.setText(title);
	}

	public void setMessage(String textbox1, String textbox2) {
		tvCheckbox1.setText(textbox1);
		tvCheckbox2.setText(textbox2);
	}

	public void setTextBtnLeft(String text) {
		myBtnLeft.setText(text);
	}

	public void setOnClickTop(OnClickLeft onClickleft) {
		this.OnClickLeft = onClickleft;
	}

	public void setOnClickBottom(OnClickRight onClickRight) {
		this.OnClickRight = onClickRight;
	}

//	public void showIcon() {
//		findViewById(R.id.img_online).setVisibility(View.VISIBLE);
//		findViewById(R.id.img_offline).setVisibility(View.VISIBLE);
//	}

	public void show() {
		super.show();
	}

	public static interface OnClickLeft {
		public void Click();
	}

	public static interface OnClickRight {
		public void Click();
	}

}
