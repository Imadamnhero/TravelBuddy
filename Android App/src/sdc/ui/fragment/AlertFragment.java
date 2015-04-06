package sdc.ui.fragment;

import java.util.ArrayList;
import java.util.List;

import sdc.application.TravelPrefs;
import sdc.data.User;
import sdc.data.database.adapter.UserTableAdapter;
import sdc.data.database.adapter.UsersInGroupTableAdapter;
import sdc.net.webservice.SendAlertWS;
import sdc.travelapp.R;
import sdc.ui.adapter.ListGroupAlertAdapter;
import sdc.ui.customview.CustomDialog;
import sdc.ui.travelapp.MainActivity;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.CompoundButton.OnCheckedChangeListener;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.Toast;

public class AlertFragment extends BaseTripFragment {
	public static final String TITLE = "Alert";
	private ListView mListView;
	private ListGroupAlertAdapter mAdapter;
	private CheckBox mCheckBoxAll;
	private boolean mByCode;
	private EditText tvAlert;
	private int mUserId;
	private int mTripId;
	private List<User> mListFriend;

	public AlertFragment() {
		super(TITLE);
	}

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		View root = inflater.inflate(R.layout.fragment_alert, container, false);
		tvAlert = (EditText) root.findViewById(R.id.et1);
		return root;
	}

	@Override
	protected void addListener() {
		super.addListener();
		mCheckBoxAll = (CheckBox) getView().findViewById(R.id.cb1);
		mCheckBoxAll.setOnCheckedChangeListener(new OnCheckedChangeListener() {
			@Override
			public void onCheckedChanged(CompoundButton buttonView,
					boolean isChecked) {
				if (!mByCode)
					mAdapter.setCheckingAll(isChecked);
			}
		});
		getView().findViewById(R.id.btn1).setOnClickListener(
				new View.OnClickListener() {
					@Override
					public void onClick(View v) {
						if (!tvAlert.getText().toString().equals("")
								&& !mAdapter.notcheckAny()) {
							showConfirmDialog(getString(R.string.confirm_send_alert));
						} else {

							if (tvAlert.getText().toString().equals(""))
								Toast.makeText(getActivity(),
										getString(R.string.toast_alert_error),
										Toast.LENGTH_SHORT).show();
							else if (mAdapter.notcheckAny())
								Toast.makeText(
										getActivity(),
										getString(R.string.toast_alert_error_noone),
										Toast.LENGTH_SHORT).show();
						}
					}
				});
	}

	@Override
	protected void initComponents() {
		mListView = (ListView) getView().findViewById(R.id.listView1);
		mListFriend = new ArrayList<User>();
		mAdapter = new ListGroupAlertAdapter(getActivity(), mListFriend);
		mAdapter.setCallBack(this);
		mListView.setAdapter(mAdapter);
	}

	@Override
	public void preLoadData() {
		mUserId = (Integer) TravelPrefs.getData(getActivity(),
				TravelPrefs.PREF_USER_ID);
		mTripId = (Integer) TravelPrefs.getData(getActivity(),
				TravelPrefs.PREF_TRIP_ID);
		List<Integer> listFr = new UsersInGroupTableAdapter(getActivity())
				.getFriendNotPending(mTripId, mUserId);
		if (listFr != null) {
			mListFriend.clear();
			mListFriend.addAll(new UserTableAdapter(getActivity())
					.getUsersFromUserIds(listFr));
			mAdapter.notifyDataSetChanged();
		}
	}

	public void setCheckBox(boolean isCheck) {
		mByCode = true;
		mCheckBoxAll.setChecked(isCheck);
		mByCode = false;
	}
	

	protected void showConfirmDialog(String text) {
		CustomDialog dialog = new CustomDialog(getActivity(), getActivity()
				.getString(R.string.choose_picture_title), text);
		dialog.getWindow().setBackgroundDrawable(
				new ColorDrawable(android.graphics.Color.TRANSPARENT));
		dialog.setOnClickLeft(new CustomDialog.OnClickLeft() {

			@Override
			public void click() {
				MainActivity activity = (MainActivity) getActivity();
				new SendAlertWS(activity).fetchData(activity.getUserId(),
						mAdapter.getIdIsChecking(), tvAlert.getText()
								.toString());
				Toast.makeText(getActivity(), getString(R.string.toast_alert),
						Toast.LENGTH_SHORT).show();
			}
		});
		dialog.setOnClickRight(new CustomDialog.OnClickRight() {

			@Override
			public void click() {
			}
		});
		dialog.show();
		dialog.setTextBtn(getActivity().getString(R.string.btn_yes),
				getActivity().getString(R.string.btn_no));
	}
}