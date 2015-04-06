package sdc.ui.customview;

import sdc.net.listeners.IWebServiceListener;
import sdc.net.webservice.BaseWS;
import sdc.net.webservice.ForgotPassWS;
import sdc.travelapp.R;
import sdc.ui.travelapp.MainActivity;
import sdc.ui.utils.StringUtils;
import android.app.Dialog;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.util.Pair;
import android.view.View;
import android.view.Window;
import android.widget.EditText;
import android.widget.Toast;

public class ForgotPassDialog extends Dialog implements View.OnClickListener,
		IWebServiceListener {
	private EditText mEdtEmail;
	private MainActivity activity;

	public ForgotPassDialog(MainActivity context) {
		super(context);
		activity = context;
	}

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.dialog_forgot_pass);
		this.getWindow().setBackgroundDrawable(
				new ColorDrawable(android.graphics.Color.TRANSPARENT));
		setCancelable(false);
		findViewById(R.id.btn_left).setOnClickListener(this);
		findViewById(R.id.btn_right).setOnClickListener(this);
		mEdtEmail = (EditText) findViewById(R.id.editText1);
	}

	@Override
	public void onClick(View v) {
		switch (v.getId()) {
		case R.id.btn_left:
			String email = mEdtEmail.getText().toString();
			if (email.length() > 0 && StringUtils.isEmailValid(email)) {
				new ForgotPassWS(this).fetchData(email);
				activity.showProgressDialog(
						activity.getString(R.string.title_sending_mail),
						activity.getString(R.string.wait_in_sec), null);

			} else
				Toast.makeText(
						getContext(),
						getContext().getString(
								R.string.toast_invalidate_sendmail),
						Toast.LENGTH_SHORT).show();
			break;
		case R.id.btn_right:
			dismiss();
			break;

		default:
			break;
		}
	}

	@SuppressWarnings({ "rawtypes", "unchecked" })
	@Override
	public void onConnectionDone(BaseWS wsControl, int type, String result) {
		if (type == BaseWS.FORGOT_PASS) {
			Pair<Integer, String> res = (Pair<Integer, String>) wsControl
					.parseData(result);
			Toast.makeText(
					getContext(),
					res == null ? getContext().getString(
							R.string.toast_uncaught_prob) : res.second,
					Toast.LENGTH_SHORT).show();
			activity.dismissProgressDialog();
			dismiss();
		}
	}

	@Override
	public void onConnectionOpen(int type) {

	}

	@Override
	public void onConnectionError(int type, String fault) {
		Toast.makeText(getContext(),
				getContext().getString(R.string.toast_problem_network),
				Toast.LENGTH_SHORT).show();
		activity.dismissProgressDialog();
	}
}
