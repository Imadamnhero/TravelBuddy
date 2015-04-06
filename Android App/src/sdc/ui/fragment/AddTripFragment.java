package sdc.ui.fragment;

import java.text.ParseException;
import java.util.Calendar;
import java.util.Date;

import sdc.application.TravelPrefs;
import sdc.net.webservice.AddTripWS;
import sdc.travelapp.R;
import sdc.ui.travelapp.MainActivity;
import sdc.ui.travelapp.MainActivity.Screen;
import sdc.ui.utils.DateTimeUtils;
import sdc.ui.utils.StringUtils;
import android.app.DatePickerDialog;
import android.app.DatePickerDialog.OnDateSetListener;
import android.content.DialogInterface;
import android.content.DialogInterface.OnCancelListener;
import android.os.Bundle;
import android.text.Editable;
import android.text.Selection;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.DatePicker;
import android.widget.EditText;
import android.widget.TextView;

public class AddTripFragment extends BaseTripFragment implements
		View.OnClickListener, View.OnFocusChangeListener {
	public static final String TITLE = "Add Trip";
	// private LinearLayout listGroup;
	private int mEdtEditingId;
	private EditText etBudget, etFromDate, etToDate, etNameTrip;
	private AddTripWS mAddTripWS;

	public AddTripFragment() {
		super(TITLE);
	}

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		View root = inflater.inflate(R.layout.fragment_addtrip, container,
				false);
		return root;
	}

	@Override
	protected void addListener() {
		super.addListener();
		getView().findViewById(R.id.btn_cross).setOnClickListener(this);
		getView().findViewById(R.id.btn_tick).setOnClickListener(this);
		etFromDate.setOnFocusChangeListener(this);
		etToDate.setOnFocusChangeListener(this);
		// getView().findViewById(R.id.btn2).setOnClickListener(this);
		etBudget.addTextChangedListener(new TextWatcher() {
			@Override
			public void onTextChanged(CharSequence s, int start, int before,
					int count) {
			}

			@Override
			public void beforeTextChanged(CharSequence s, int start, int count,
					int after) {
			}

			@Override
			public void afterTextChanged(Editable s) {
				if (!s.toString().contains("$") && s.length() != 0) {
					etBudget.setText("$ " + s.toString());
					Selection.setSelection(etBudget.getText(), etBudget
							.getText().length());
				} else if (s.length() == 2) {
					etBudget.setText("");
				}
			}
		});
	}

	@Override
	protected void initComponents() {
		// listGroup = (LinearLayout) getView().findViewById(R.id.list_group);
		etFromDate = (EditText) getView().findViewById(R.id.from_d);
		Date d = new Date();
		etFromDate.setHint(DateTimeUtils.sDateFormat.format(d));
		etToDate = (EditText) getView().findViewById(R.id.to_d);
		etToDate.setHint(DateTimeUtils.sDateFormat.format(d));
		etBudget = (EditText) getView().findViewById(R.id.et1);
		etNameTrip = (EditText) getView().findViewById(R.id.autocomplete);
		mAddTripWS = new AddTripWS((MainActivity) getActivity());
		// autoCompleteText = (AutoCompleteTextView) getView().findViewById(
		// R.id.autocomplete);
		// autoCompleteText.setAdapter(new PlacesAutoCompleteAdapter(
		// getActivity(), android.R.layout.simple_list_item_1));
	}

	@Override
	public void preLoadData() {
	}

	// public void addRowListGroup(ViewGroup parent) {
	// int[] imageId = { R.drawable.im1, R.drawable.im2, R.drawable.im3,
	// R.drawable.im4, R.drawable.im1, R.drawable.im2 };
	// int userId = (Integer)TravelPrefs.getData(getActivity(),
	// TravelPrefs.PREF_USER_ID);
	// User[] listFr = new UsersInGroupTableAdapter(getActivity())
	// .getUsersInATrip(tripId, userId);
	// LayoutInflater inflater = LayoutInflater.from(getActivity());
	// for (int i = 0; i < listFr.length; i++) {
	// View rowView = inflater.inflate(R.layout.row_list_group, parent,
	// false);
	// TextView nameFr = (TextView) rowView.findViewById(R.id.textView1);
	// nameFr.setText(listFr[i].getName());
	// ImageView img = (ImageView) rowView.findViewById(R.id.img_group2);
	// img.setImageResource(imageId[i]);
	// parent.addView(rowView);
	// }
	// }

	@Override
	public void onClick(View v) {
		MainActivity mother = (MainActivity) getActivity();
		switch (v.getId()) {
		case R.id.btn_cross:
			mother.changeScreen(Screen.HOME);
			break;
		case R.id.btn_tick:
			String name = etNameTrip.getText().toString();
			String fromDate = etFromDate.getText().toString();
			String toDate = null;
			toDate = etToDate.getText().toString();
			String strBudget = etBudget.getText().toString();
			double budget = Double
					.parseDouble(strBudget.length() > 0 ? strBudget.split(" ")[1]
							: "0");
			if (validInput(name, fromDate, toDate, budget)) {
				mother.showProgressDialog(getString(R.string.title_addtrip),
						getString(R.string.wait_in_sec),
						new OnCancelListener() {
							@Override
							public void onCancel(DialogInterface dialog) {
								mAddTripWS.cancelFetchTask();
							}
						});
				int userId = (Integer) TravelPrefs.getData(getActivity(),
						TravelPrefs.PREF_USER_ID);
				mAddTripWS.fetchData(name, userId, fromDate, toDate, budget);
			}
			break;
		case R.id.btn2:
			mother.changeScreen(Screen.INVITE);
			break;

		default:
			break;
		}
	}

	private boolean validInput(String name, String fromDate, String toDate,
			double budget) {
		MainActivity activity = (MainActivity) getActivity();
		if (TextUtils.isEmpty(name)) {
			activity.showToast(getString(R.string.toast_blank_tripname) + "\n");
		} else if (StringUtils.isOnlyContainSpace(name)) {
			activity.showToast(getString(R.string.toast_invalid_tripname)
					+ "\n");
		} else if (TextUtils.isEmpty(fromDate)) {
			activity.showToast(getString(R.string.toast_blank_date) + "\n");
		} else if (TextUtils.isEmpty(toDate)) {
			activity.showToast(getString(R.string.toast_blank_date) + "\n");
		} else if (!DateTimeUtils.compareDate(fromDate, toDate)) {
			activity.showToast(getString(R.string.toast_invalid_date) + "\n");
		} else if (budget == 0) {
			activity.showToast(getString(R.string.toast_blank_budget) + "\n");
		} else if (budget < 0) {
			activity.showToast(getString(R.string.toast_invalid_budget) + "\n");
		} else {
			return true;
		}
		return false;
	}

	@Override
	public void onFocusChange(View v, boolean hasFocus) {
		if (hasFocus) {
			switch (v.getId()) {
			case R.id.from_d:
				mEdtEditingId = R.id.from_d;
				showDateTimeDialog(1);
				break;
			case R.id.to_d:
				mEdtEditingId = R.id.to_d;
				showDateTimeDialog(2);
			default:
				break;
			}
		}
	}

	/**
	 * @param type
	 *            =1 if show dialog of fromdate, =2 if show dialog of todate
	 */
	private void showDateTimeDialog(int type) {
		Calendar cal = Calendar.getInstance();
		if (type == 1) {
			String toDate = etToDate.getText() + "";
			if (toDate.length() > 0) {
				Date d;
				try {
					d = DateTimeUtils.sDateFormat.parse(toDate);
					cal.setTime(d);
				} catch (java.text.ParseException e) {
					e.printStackTrace();
				}
			}
		} else if (type == 2) {
			String fromDate = etFromDate.getText() + "";
			if (fromDate.length() > 0) {
				Date d;
				try {
					d = DateTimeUtils.sDateFormat.parse(fromDate);
					cal.setTime(d);
				} catch (java.text.ParseException e) {
					e.printStackTrace();
				}
			}
		}
		new DatePickerDialog(getActivity(), new OnDateSetListener() {
			@Override
			public void onDateSet(DatePicker view, int year, int monthOfYear,
					int dayOfMonth) {
				TextView tv = (TextView) getView().findViewById(mEdtEditingId);
				tv.setText((monthOfYear + 1) + "-" + dayOfMonth + "-" + year);
				tv.clearFocus();
			}
		}, cal.get(Calendar.YEAR), cal.get(Calendar.MONTH),
				cal.get(Calendar.DAY_OF_MONTH)).show();

	}
}
