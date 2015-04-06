package sdc.ui.customview;

import sdc.travelapp.R;
import sdc.ui.customview.CustomDialog.OnClickLeft;
import sdc.ui.customview.CustomDialog.OnClickRight;
import android.app.Dialog;
import android.content.Context;
import android.os.Bundle;
import android.view.Gravity;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.TextView;

public class CustomChoosePictureDialog extends Dialog {
	private String title, line1, line2;
	private TextView tvCheckbox1, tvCheckbox2, myTvTitle;
	private View myLL1, myLL2;
	public OnClickLeft OnClickLeft;
	public OnClickRight OnClickRight;
	private TextView myBtnLeft;

	public CustomChoosePictureDialog(Context context, String title,
			String line1, String line2) {
		super(context);
		this.title = title;
		this.line1 = line1;
		this.line2 = line2;
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
		setCancelable(false);
		// init();
	}

	public void init() {

	}

	public void setTitle(String title) {
		myTvTitle.setText(title);
	}

	public void show() {
		super.show();
	}

}
