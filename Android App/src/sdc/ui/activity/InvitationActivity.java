package sdc.ui.activity;

import sdc.application.TravelPrefs;
import sdc.data.database.adapter.ExpenseTableAdapter;
import sdc.net.listeners.IWebServiceListener;
import sdc.net.webservice.BaseWS;
import sdc.net.webservice.ReplyInvitationWS;
import sdc.travelapp.R;
import sdc.ui.travelapp.MainActivity;
import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;

import com.nostra13.universalimageloader.core.ImageLoader;

public class InvitationActivity extends Activity implements IWebServiceListener {
	private ProgressBar mProgressBar;
	private ReplyInvitationWS mWebservice;
	private Button btnAccept, btnDecline;
	private boolean isAccept;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_invitation);

		// get data
		Intent receivedIntent = getIntent();
		String msg = receivedIntent.getStringExtra("msg");
		String avaUrl = receivedIntent.getStringExtra("avatar");
		final int invitedId = receivedIntent.getIntExtra("invited_id", -1);
		final int inviterId = receivedIntent.getIntExtra("inviter_id", -1);
		final int tripId = receivedIntent.getIntExtra("tripid", -1);

		// init view and add event
		btnAccept = (Button) findViewById(R.id.btn_accept);
		btnDecline = (Button) findViewById(R.id.btn_decline);
		mProgressBar = (ProgressBar) findViewById(R.id.progressBar1);
		ImageView ava = (ImageView) findViewById(R.id.imageView1);
		ImageLoader.getInstance().displayImage(BaseWS.HOST + avaUrl, ava);
		((TextView) findViewById(R.id.tv_msg)).setText(msg);

		TextView tvMessage2 = (TextView) findViewById(R.id.tv_msg2);
		if (((Integer) TravelPrefs.getData(this, TravelPrefs.PREF_TRIP_ID)) > 0) {
			tvMessage2.setVisibility(View.VISIBLE);
			tvMessage2.setText(receivedIntent.getStringExtra("msg2"));
		}
		btnAccept.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View v) {
				mProgressBar.setVisibility(View.VISIBLE);
				btnAccept.setEnabled(false);
				btnDecline.setEnabled(false);
				mWebservice.fetchData(inviterId, invitedId, tripId, 1);
				isAccept = true;
			}
		});
		btnDecline.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View v) {
				mProgressBar.setVisibility(View.VISIBLE);
				btnAccept.setEnabled(false);
				btnDecline.setEnabled(false);
				mWebservice.fetchData(inviterId, invitedId, tripId, 0);
				isAccept = false;
			}
		});
		mWebservice = new ReplyInvitationWS(this);
	}

	@Override
	protected void onStop() {
		super.onStop();
		mWebservice.cancelFetchTask();
	}

	@Override
	public void onConnectionDone(
			@SuppressWarnings("rawtypes") BaseWS wsControl, int type,
			String result) {
		mProgressBar.setVisibility(View.GONE);
		btnAccept.setEnabled(true);
		btnDecline.setEnabled(true);
		switch (type) {
		case BaseWS.REPLY_INVITE:
			String message = (String) wsControl.parseData(result);
			if (message != null && message.equals("")) {
				if (isAccept) {

					int user_id = (Integer) TravelPrefs.getData(this,
							TravelPrefs.PREF_USER_ID);
					new ExpenseTableAdapter(this).deleteExpenseOfUser(user_id);
					int trip_id = (Integer) TravelPrefs.getData(this,
							TravelPrefs.PREF_TRIP_ID);
					MainActivity.clearDataOfTrip(this, user_id, trip_id);
					TravelPrefs.putData(InvitationActivity.this,
							TravelPrefs.PREF_IS_ADDED_BUGET, false);
					TravelPrefs.putData(InvitationActivity.this,
							TravelPrefs.PREF_TRIP_ID, trip_id);
					Intent goToHome = new Intent(InvitationActivity.this,
							MainActivity.class);
					startActivity(goToHome);
				}
				this.finish();
			} else if (message != null) {
				Toast.makeText(this, message, Toast.LENGTH_LONG).show();
			}
			break;
		default:
			break;
		}
	}

	@Override
	public void onConnectionError(int type, String fault) {
		mProgressBar.setVisibility(View.GONE);
		btnAccept.setEnabled(true);
		btnDecline.setEnabled(true);
		Toast.makeText(this, this.getString(R.string.toast_problem_network),
				Toast.LENGTH_LONG).show();
	}

	@Override
	public void onConnectionOpen(int type) {
	}
}
