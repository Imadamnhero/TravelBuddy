package sdc.ui.customview;

import sdc.travelapp.R;
import sdc.ui.fragment.PackingFragment;
import android.app.Dialog;
import android.content.Context;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.view.View;
import android.view.Window;
import android.widget.EditText;

public class AddItemDialog extends Dialog implements View.OnClickListener {
	private PackingFragment mCallback;

	public AddItemDialog(Context context, PackingFragment callback) {
		super(context);
		mCallback = callback;
	}

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.dialog_additem);
		this.getWindow().setBackgroundDrawable(
				new ColorDrawable(android.graphics.Color.TRANSPARENT));
		setCancelable(false);
		findViewById(R.id.btn_cancel).setOnClickListener(this);
		findViewById(R.id.btn_right).setOnClickListener(this);
	}

	@Override
	public void onClick(View v) {
		switch (v.getId()) {
		case R.id.btn_cancel:
			dismiss();
			break;
		case R.id.btn_right:
			String strItem = ((EditText) findViewById(R.id.editText1))
					.getText().toString();
			mCallback.addItemPacking(strItem);
			dismiss();
			break;
		default:
			break;
		}
	}
}
