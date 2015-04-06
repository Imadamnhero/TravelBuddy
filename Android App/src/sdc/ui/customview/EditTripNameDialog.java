package sdc.ui.customview;

import sdc.application.TravelApplication;
import sdc.application.TravelPrefs;
import sdc.data.database.adapter.TripTableAdapter;
import sdc.net.listeners.IWebServiceListener;
import sdc.net.webservice.BaseWS;
import sdc.net.webservice.EditTripNameWS;
import sdc.travelapp.R;
import sdc.ui.travelapp.MainActivity;
import sdc.ui.utils.StringUtils;
import android.app.Dialog;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.view.Window;
import android.widget.EditText;
import android.widget.Toast;

public class EditTripNameDialog extends Dialog implements View.OnClickListener,
		IWebServiceListener {
	private String mTripName;
	private EditText etTripName;
	private int mUserId;
	private MainActivity mCallBack;

	public EditTripNameDialog(MainActivity callBack, String oldTripName) {
		super(callBack);
		mTripName = oldTripName;
		mCallBack = callBack;
	}

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.dialog_edit_tripname);
		this.getWindow().setBackgroundDrawable(
				new ColorDrawable(android.graphics.Color.TRANSPARENT));
		setCancelable(false);
		etTripName = (EditText) findViewById(R.id.editText1);
		if (mTripName.length() > 0) {
			etTripName.setText(mTripName);
		}
		findViewById(R.id.btn_right).setOnClickListener(this);
		findViewById(R.id.btn_cancel).setOnClickListener(this);
		mUserId = (Integer) TravelPrefs.getData(getContext(),
				TravelPrefs.PREF_USER_ID);
	}

	@Override
	public void onClick(View v) {
		switch (v.getId()) {
		case R.id.btn_right:
			if (TravelApplication.isOnline(getContext())) {
				String newName = etTripName.getText() + "";
				if (TextUtils.isEmpty(newName)
						|| StringUtils.isOnlyContainSpace(newName)) {
					etTripName.setText(mTripName);
					Toast.makeText(getContext(),
							R.string.toast_invalid_tripname, Toast.LENGTH_SHORT)
							.show();
					return;
				} else {
					mTripName = newName;
					mCallBack.showProgressDialog(
							getContext().getString(R.string.tv_edit_tripname),
							getContext().getString(R.string.wait_in_sec), null);
					new EditTripNameWS(this).fetchData(mTripName, mUserId);
				}
			} else {
				Toast.makeText(getContext(), R.string.toast_problem_network,
						Toast.LENGTH_SHORT).show();
				dismiss();
			}
			break;
		case R.id.btn_cancel:
			dismiss();
			break;
		}
	}

	@SuppressWarnings("rawtypes")
	@Override
	public void onConnectionDone(BaseWS wsControl, int type, String result) {
		switch (type) {
		case BaseWS.EDIT_TRIPNAME:
			new TripTableAdapter(getContext()).updateTripName(mTripName,
					mUserId);
			mCallBack.dismissProgressDialog();
			this.dismiss();
			mCallBack.reloadCurFragment();
			break;
		default:
			break;
		}

	}

	@Override
	public void onConnectionError(int type, String fault) {
	}

	@Override
	public void onConnectionOpen(int type) {
	}

}
