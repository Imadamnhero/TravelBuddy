package sdc.ui.fragment;

import sdc.application.TravelApplication;
import sdc.application.TravelPrefs;
import sdc.net.webservice.LoginWS;
import sdc.travelapp.R;
import sdc.ui.customview.ForgotPassDialog;
import sdc.ui.travelapp.MainActivity;
import sdc.ui.travelapp.MainActivity.Screen;
import sdc.ui.utils.StringUtils;
import android.content.DialogInterface;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.EditText;

public class LoginFragment extends BaseHomeFragment implements
		View.OnClickListener {
	private EditText mEdtEmail;
	private EditText mEdtPass;
	private CheckBox mCheckBox;
	private LoginWS mLoginWS;

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		View root = inflater.inflate(R.layout.fragment_login, container, false);
		return root;
	}

	@Override
	protected void addListener() {
		super.addListener();
		getView().findViewById(R.id.btn_login).setOnClickListener(this);
		getView().findViewById(R.id.tv_link).setOnClickListener(this);
		getView().findViewById(R.id.tv_forgot).setOnClickListener(this);
		mCheckBox
				.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {

					@Override
					public void onCheckedChanged(CompoundButton buttonView,
							boolean isChecked) {
						TravelPrefs.putData(getActivity(),
								TravelPrefs.PREF_REMEMBER, isChecked);
					}
				});
	}

	@Override
	protected void initComponents() {
		getView().findViewById(R.id.title_btn_menu).setVisibility(View.GONE);
		mEdtEmail = (EditText) getView().findViewById(R.id.et_email);
		mEdtPass = (EditText) getView().findViewById(R.id.et_password);
		mLoginWS = new LoginWS((MainActivity) getActivity(), getActivity());
		mCheckBox = (CheckBox) getView().findViewById(R.id.checkBox1);
	}

	@Override
	public void preLoadData() {
		String mail = (String) TravelPrefs.getData(getActivity(),
				TravelPrefs.PREF_USER_MAIL);
		String pass = (String) TravelPrefs.getData(getActivity(),
				TravelPrefs.PREF_USER_PASS);
		mEdtEmail.setText(mail);
		mEdtPass.setText(pass);
		mCheckBox.setChecked((Boolean) TravelPrefs.getData(getActivity(),
				TravelPrefs.PREF_REMEMBER));
		TravelApplication app = (TravelApplication) getActivity()
				.getApplication();
		if (mail.length() > 0 && pass.length() > 0 && app.isAutoLogin()) {
			app.setAutoLogin(false);
			login();
		}
	}

	@Override
	public void onClick(View v) {
		MainActivity activity = ((MainActivity) getActivity());
		if (v.getId() == R.id.btn_login) {
			if (!mCheckBox.isChecked()) {
				TravelPrefs.putData(getActivity(), TravelPrefs.PREF_USER_MAIL,
						"");
				TravelPrefs.putData(getActivity(), TravelPrefs.PREF_USER_PASS,
						"");
			}
			login();
		} else if (v.getId() == R.id.tv_link) {
			activity.changeScreen(Screen.CREATE_ACC);
		} else if (v.getId() == R.id.tv_forgot) {
			new ForgotPassDialog(activity).show();
		}
	}

	public void login() {
		MainActivity activity = ((MainActivity) getActivity());
		String mail = mEdtEmail.getText() + "";
		String pass = mEdtPass.getText() + "";
		if (validateInput(mail, pass)) {
			mLoginWS.fetchData(mail, pass);
			activity.showProgressDialog(getString(R.string.tv_login),
					getString(R.string.wait_in_sec),
					new DialogInterface.OnCancelListener() {
						@Override
						public void onCancel(DialogInterface dialog) {
							mLoginWS.cancelFetchTask();
						}
					});
			mEdtPass.setText("");
		}
	}

	private boolean validateInput(String mail, String pass) {
		MainActivity activity = ((MainActivity) getActivity());
		if (TextUtils.isEmpty(mail)) {
			activity.showToast(getString(R.string.toast_blank_mail) + "\n");
		} else if (!StringUtils.isEmailValid(mail)) {
			activity.showToast(getString(R.string.toast_invalid_mail) + "\n");
		} else if (TextUtils.isEmpty(pass)) {
			activity.showToast(getString(R.string.toast_blank_pass) + "\n");
		}else {
			return true;
		}
		return false;
	}

}
