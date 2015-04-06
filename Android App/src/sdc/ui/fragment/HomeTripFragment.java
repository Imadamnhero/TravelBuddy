package sdc.ui.fragment;

import java.util.List;

import sdc.application.TravelApplication;
import sdc.application.TravelPrefs;
import sdc.data.Expense;
import sdc.data.Photo;
import sdc.data.Trip;
import sdc.data.database.adapter.ExpenseTableAdapter;
import sdc.data.database.adapter.PhotoTableAdapter;
import sdc.data.database.adapter.TripTableAdapter;
import sdc.net.webservice.AddBudgetWS;
import sdc.net.webservice.EndTripWS;
import sdc.net.webservice.GetUsersInGroupWS;
import sdc.net.webservice.SyncPhotosWS;
import sdc.travelapp.R;
import sdc.ui.customview.CustomDialog;
import sdc.ui.customview.CustomSingleChoiceDialog;
import sdc.ui.customview.EditTripNameDialog;
import sdc.ui.travelapp.MainActivity;
import sdc.ui.travelapp.MainActivity.Screen;
import sdc.ui.utils.StringUtils;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;

public class HomeTripFragment extends BaseTripFragment implements
		View.OnClickListener {
	public static final String TAG = "HomeTripScreen";
	public static final String TITLE = "LOCATION";
	private View mFrame1, mFrame2, mFrame3, mBudgetFrame, mBudgetInputFrame;
	private TextView mTvFromDate, mTvToDate, mTvBudget, mTvYourPhoto,
			mTvGroupPhoto;
	private EditText mEtBudget;
	private int mTripId;
	private int mUserId;
	private Trip mTripInfo; // note: don't use tripname, tripid, userid in this
							// object
	private ProgressBar bar;
	private MainActivity mContext;

	public HomeTripFragment() {
		super(TITLE);
	}

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		View root = inflater.inflate(R.layout.fragment_home_trip, container,
				false);
		mContext = (MainActivity) getActivity();
		mContext.SyncAllData();
		return root;
	}

	@Override
	protected void addListener() {
		super.addListener();
		getView().findViewById(R.id.btn_addphoto).setOnClickListener(this);
		getView().findViewById(R.id.btnadd).setOnClickListener(this);
		getView().findViewById(R.id.btn1).setOnClickListener(this);
		getView().findViewById(R.id.btn2).setOnClickListener(this);
		getView().findViewById(R.id.btn_endtrip).setOnClickListener(this);
		getView().findViewById(R.id.btn3).setOnClickListener(this);
		getView().findViewById(R.id.btn_back1).setOnClickListener(this);
		getView().findViewById(R.id.btn_back2).setOnClickListener(this);
		getView().findViewById(R.id.btn4).setOnClickListener(this);
		getView().findViewById(R.id.btn5).setOnClickListener(this);
		getView().findViewById(R.id.title_trip).setOnClickListener(this);
		getView().findViewById(R.id.btn_add_budget).setOnClickListener(this);
		NotesFragment.syncNoteData(mContext);
		ExpensesFragment.syncExpenseCategories(mContext);
		new GetUsersInGroupWS(mContext, mContext);

	}

	@Override
	protected void initComponents() {
		mFrame1 = getView().findViewById(R.id.frame1);
		mFrame2 = getView().findViewById(R.id.frame2);
		mFrame3 = getView().findViewById(R.id.frame3);
		mTvFromDate = (TextView) getView().findViewById(R.id.tv_fromdate);
		mTvToDate = (TextView) getView().findViewById(R.id.tv_todate);
		mTvBudget = (TextView) getView().findViewById(R.id.tv_budget);
		mTvYourPhoto = (TextView) getView().findViewById(R.id.tv_your_photo);
		mTvGroupPhoto = (TextView) getView().findViewById(R.id.tv_group_photo);
		mEtBudget = (EditText) getView().findViewById(R.id.et1);
		mBudgetFrame = getView().findViewById(R.id.frame_budget);
		mBudgetInputFrame = getView().findViewById(R.id.frame_addbudget);
		bar = (ProgressBar) getView().findViewById(R.id.progress_bar);
	}

	@Override
	public void preLoadData() {
		MainActivity activity = (MainActivity) getActivity();
		mTripId = (Integer) TravelPrefs.getData(getActivity(),
				TravelPrefs.PREF_TRIP_ID);
		mUserId = (Integer) TravelPrefs.getData(getActivity(),
				TravelPrefs.PREF_USER_ID);
		mTripInfo = new TripTableAdapter(activity).getTrip(mTripId, mUserId);
		mTvFromDate.setText(mTripInfo.getFromDate());
		mTvToDate.setText(mTripInfo.getToDate());
		super.setTitle(mTripInfo.getTripName());
		if (mTripInfo.getBudget() == -1) {
			mBudgetInputFrame.setVisibility(View.VISIBLE);
			mBudgetFrame.setVisibility(View.GONE);
		} else {
			mBudgetInputFrame.setVisibility(View.GONE);
			mBudgetFrame.setVisibility(View.VISIBLE);
			mTvBudget.setText("$ "
					+ StringUtils.sExpensiveNumberFormat.format(mTripInfo
							.getBudget()));
		}
		initExpenseData(activity,
				new ExpenseTableAdapter(activity).getExpenseOfUser(mUserId),
				new TripTableAdapter(activity).getTrip(mTripId, mUserId)
						.getBudget());
		Log.i("expense",
				new ExpenseTableAdapter(activity).getExpenseOfUser(mUserId)
						+ "");
		int groupPhoto = (Integer) TravelPrefs.getData(getActivity(),
				TravelPrefs.PREF_GROUP_PHOTO);
		int yourPhoto = new PhotoTableAdapter(getActivity())
				.countPhotosOfAUser(mUserId, mTripId);
		mTvGroupPhoto.setText(groupPhoto + "");
		mTvYourPhoto.setText(yourPhoto + "");

		if (mTripId >= 0 && mUserId > 0)
			if (TravelApplication.isOnline(mContext))
				SyncPhotosWS.doUpload(mContext, mUserId, mTripId);

	}

	@SuppressLint("UseSparseArrays")
	private void initExpenseData(Activity activity, List<Expense> data,
			double tripBudget) {
		// MainActivity activity = (MainActivity) getActivity();
		/*
		 * List<Expense> data = new ExpenseTableAdapter(activity)
		 * .getExpenseOfUser(activity.getUserId());
		 */
		/*
		 * double tripBudget = new TripTableAdapter(getActivity()).getTrip(
		 * activity.getTripId(), activity.getUserId()).getBudget();
		 */
		float total = 0;
		if (data != null) {
			for (Expense expense : data)
				total += expense.getMoney();
			((TextView) getView().findViewById(R.id.tv_spent)).setText("$ "
					+ StringUtils.sExpensiveNumberFormat.format(total));
			((TextView) getView().findViewById(R.id.tv_remain)).setText("$ "
					+ StringUtils.sExpensiveNumberFormat
							.format((tripBudget - total)));
			bar.setMax((int) tripBudget);
			bar.setProgress((int) total);
		} else {
			((TextView) getView().findViewById(R.id.tv_spent))
					.setText("$ 0.00");
			((TextView) getView().findViewById(R.id.tv_remain)).setText("$ "
					+ StringUtils.sExpensiveNumberFormat.format(tripBudget));
			bar.setMax((int) tripBudget);
			bar.setProgress(0);
		}
	}

	@Override
	public void onClick(View v) {
		MainActivity mother = (MainActivity) getActivity();
		switch (v.getId()) {
		case R.id.btn_addphoto:
			showDialogPhoto("Travel Buddy");
			break;
		case R.id.btnadd: // expenses
			mContext.hideSoftKeyBoard();
			mother.changeScreen(Screen.ADD_EXPENSES);
			break;
		case R.id.btn1: // move to send receipts
			changeFrame(View.GONE, View.VISIBLE, View.GONE);
			break;
		case R.id.btn2: // move to send slideshow
			mContext.changeScreen(Screen.REVIEW_SLIDESHOW);
			// changeFrame(View.GONE, View.GONE, View.VISIBLE);
			break;
		case R.id.btn_endtrip:
			showEndTripDialog();
			break;
		case R.id.btn3: // send receipt
			sendReceipt();
			break;
		case R.id.btn_back1:
			changeFrame(View.VISIBLE, View.GONE, View.GONE);
			break;
		case R.id.btn4: // send email

			break;
		case R.id.btn5: // send fb

			break;
		case R.id.btn_back2:
			changeFrame(View.VISIBLE, View.GONE, View.GONE);
			break;
		case R.id.title_trip:
			if (mUserId == new TripTableAdapter(mother).getTrip(mTripId,
					mUserId).getOwnerId())
				new EditTripNameDialog((MainActivity) getActivity(),
						super.getTitle()).show();
			break;
		case R.id.btn_add_budget:
			if (mEtBudget.getText().toString().length() != 0) {
				new AddBudgetWS(mother).fetchData(mUserId,
						Double.parseDouble(mEtBudget.getText().toString()));
				mBudgetInputFrame.setVisibility(View.GONE);
				mBudgetFrame.setVisibility(View.VISIBLE);
				mTripInfo.setBudget(Double.parseDouble(mEtBudget.getText()
						.toString()));
				mTvBudget.setText("$ " + mTripInfo.getBudget() + "");
				initExpenseData(mother,
						new ExpenseTableAdapter(mother)
								.getExpenseOfUser(mUserId),
						Double.parseDouble(mEtBudget.getText().toString()));
				mContext.hideSoftKeyBoard();

			} else {

				Toast.makeText(getActivity(),
						getString(R.string.toast_blank_budget),
						Toast.LENGTH_LONG).show();
			}
			break;
		default:
			break;
		}
	}

	protected void showEndTripDialog() {
		CustomDialog dialog = new CustomDialog(getActivity(),
				getString(R.string.endtrip_title),
				getString(R.string.endtrip_content));
		dialog.getWindow().setBackgroundDrawable(
				new ColorDrawable(android.graphics.Color.TRANSPARENT));
		dialog.setOnClickLeft(new CustomDialog.OnClickLeft() {

			@Override
			public void click() {
				MainActivity activity = (MainActivity) getActivity();
				new EndTripWS(activity).fetchData(mTripId, mUserId);
				activity.showProgressDialog(getString(R.string.title_deltrip),
						getString(R.string.wait_in_sec), null);
			}
		});
		dialog.setOnClickRight(new CustomDialog.OnClickRight() {

			@Override
			public void click() {
			}
		});
		dialog.show();
		dialog.setTextBtn(getString(R.string.btn_yes),
				getString(R.string.btn_no));
	}

	public void showDialogPhoto(String title) {
		final CustomSingleChoiceDialog dialog = new CustomSingleChoiceDialog(
				getActivity(), title, "Take photo",
				"Choose picture from gallery");
		dialog.getWindow().setBackgroundDrawable(
				new ColorDrawable(android.graphics.Color.TRANSPARENT));
		dialog.setOnClickTop(new CustomSingleChoiceDialog.OnClickLeft() {

			@Override
			public void Click() {
				dialog.dismiss();
				// onClickTakeAPhoto();
				((MainActivity) getActivity()).changeScreen(Screen.TAKE_PHOTO);
			}
		});
		dialog.setOnClickBottom(new CustomSingleChoiceDialog.OnClickRight() {

			@Override
			public void Click() {
				dialog.dismiss();
				// onClickChooseFromGallery();
				((MainActivity) getActivity()).changeScreen(Screen.ADD_PHOTO);
			}
		});
		try {
			dialog.show();
		} catch (Exception e) {
			Log.i(TAG, e.getMessage());
		}
		dialog.setTextBtn("Cancel");
	}

	private void changeFrame(int frame1, int frame2, int frame3) {
		mFrame1.setVisibility(frame1);
		mFrame2.setVisibility(frame2);
		mFrame3.setVisibility(frame3);
	}

	private void sendReceipt() {
		List<Photo> arrReceipt = new PhotoTableAdapter(getActivity())
				.getAllReceiptsOfUser(mContext.getUserId(),
						mContext.getTripId());
		String email = ((EditText) getView().findViewById(R.id.edit_email))
				.getText().toString();
		if (arrReceipt.size() > 0 && !email.equals("")) {
			if (!StringUtils.isEmailValid(email)) {
				Toast.makeText(getActivity(),
						getString(R.string.toast_invalidate_sendmail),
						Toast.LENGTH_SHORT).show();
			} else {
				mContext.showProgressDialog(
						getString(R.string.title_send_receipt),
						getString(R.string.wait_in_sec), null);

				mContext.showSendReceiptFragment(email, ((CheckBox) getView()
						.findViewById(R.id.cb_send)).isChecked());
			}
		} else {
			if (arrReceipt.size() <= 0) {
				Toast.makeText(getActivity(),
						getString(R.string.toast_receipt_nophoto),
						Toast.LENGTH_LONG).show();
			} else if (email.equals("")) {
				Toast.makeText(getActivity(),
						getString(R.string.toast_receipt_nomail),
						Toast.LENGTH_LONG).show();
			} else {
				Toast.makeText(getActivity(),
						getString(R.string.toast_invalid_mail),
						Toast.LENGTH_LONG).show();
			}
		}
	}

	public void updateExpensive() {
		initExpenseData(getActivity(),
				new ExpenseTableAdapter(getActivity())
						.getExpenseOfUser(mUserId), new TripTableAdapter(
						getActivity()).getTrip(mTripId, mUserId).getBudget());
	}

	public void updatePhotoCount() {
		int groupPhoto = (Integer) TravelPrefs.getData(getActivity(),
				TravelPrefs.PREF_GROUP_PHOTO);
		int yourPhoto = new PhotoTableAdapter(getActivity())
				.countPhotosOfAUser(mUserId, mTripId);
		mTvGroupPhoto.setText(groupPhoto + "");
		mTvYourPhoto.setText(yourPhoto + "");
	}
}
