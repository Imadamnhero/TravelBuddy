package sdc.ui.fragment;

import sdc.net.webservice.AddGroupWS;
import sdc.net.webservice.SendMailInviteWS;
import sdc.travelapp.R;
import sdc.ui.travelapp.MainActivity;
import sdc.ui.utils.StringUtils;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.Toast;

public class InviteFragment extends BaseTripFragment implements
		View.OnClickListener {
	public static final String TITLE = "Invite to Group";
	private EditText mEdtInvite, mEdtSendMail;

	public InviteFragment() {
		super(TITLE);
	}

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		View root = inflater
				.inflate(R.layout.fragment_invite, container, false);
		return root;
	}

	@Override
	protected void addListener() {
		super.addListener();
		changeBtnMenuToBack("");
		getView().findViewById(R.id.btn1).setOnClickListener(this);
		getView().findViewById(R.id.btn2).setOnClickListener(this);
	}

	@Override
	protected void initComponents() {
		mEdtInvite = (EditText) getView().findViewById(R.id.et2);
		mEdtSendMail = (EditText) getView().findViewById(R.id.et1);
	}

	@Override
	public void preLoadData() {
		// TODO Auto-generated method stub

	}

	@Override
	public void onClick(View v) {
		MainActivity activity = (MainActivity) getActivity();
		switch (v.getId()) {
		case R.id.btn1:
			String email = mEdtSendMail.getText().toString();
			if(email.length() == 0){
				Toast.makeText(getActivity(),
						getString(R.string.toast_blank_mail),
						Toast.LENGTH_SHORT).show();
			} else if(!StringUtils.isEmailValid(email)){
				Toast.makeText(getActivity(),
						getString(R.string.toast_invalidate_sendmail),
						Toast.LENGTH_SHORT).show();
			} else {
				activity.showProgressDialog(
						getString(R.string.title_send_mail_invite),
						getString(R.string.wait_in_sec), null);
				new SendMailInviteWS(activity).fetchData(activity.getUserId(),
						email);
				((MainActivity)getActivity()).hideSoftKeyBoard();
			}
			break;
		case R.id.btn2:
			String mail = mEdtInvite.getText().toString();
			if(mail.length() == 0){
				Toast.makeText(getActivity(),
						getString(R.string.toast_blank_mail),
						Toast.LENGTH_SHORT).show();
			} else if(!StringUtils.isEmailValid(mail)){
				Toast.makeText(getActivity(),
						getString(R.string.toast_invalidate_sendmail),
						Toast.LENGTH_SHORT).show();
			} else {
				activity.showProgressDialog(
						getString(R.string.title_send_invite),
						getString(R.string.wait_in_sec), null);
				new AddGroupWS(activity, activity).fetchData(
						activity.getUserId(), mail);
				((MainActivity)getActivity()).hideSoftKeyBoard();
			}
			break;
		default:
			break;
		}
	}
}
