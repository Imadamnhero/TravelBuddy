package sdc.ui.fragment;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.List;
import java.util.Locale;

import sdc.application.TravelPrefs;
import sdc.data.Category;
import sdc.data.Expense;
import sdc.data.database.ContentProviderDB;
import sdc.data.database.adapter.CategoryTableAdapter;
import sdc.data.database.adapter.ExpenseTableAdapter;
import sdc.travelapp.R;
import sdc.ui.customview.EditCategoriesDialog;
import sdc.ui.travelapp.MainActivity;
import sdc.ui.travelapp.MainActivity.Screen;
import android.graphics.Color;
import android.os.Bundle;
import android.text.Editable;
import android.text.Selection;
import android.text.TextWatcher;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

public class AddExpensesFragment extends BaseTripFragment implements
		View.OnClickListener {
	public static final String TITLE = "Add Expenses";
	private List<Category> mCategories;
	private int mCurCategory = 0;
	private TextView tvCategory, tvDescription;
	private EditText etBudget;
	private final int defaultColor = Color.WHITE;
	private final int editableColor = Color.parseColor("#ff9b00");

	public AddExpensesFragment() {
		super(TITLE);
	}

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		View root = inflater.inflate(R.layout.fragment_addexpenses, container,
				false);
		return root;
	}

	@Override
	protected void addListener() {
		super.addListener();
		getView().findViewById(R.id.btn1).setOnClickListener(this);
		getView().findViewById(R.id.btn2).setOnClickListener(this);
		getView().findViewById(R.id.btn_save).setOnClickListener(this);
		getView().findViewById(R.id.btnadd).setOnClickListener(this);
		tvCategory.setOnClickListener(this);
		changeBtnMenuToBack(getString(R.string.cancel_action));
	}

	@Override
	protected void initComponents() {
		tvCategory = (TextView) getView().findViewById(R.id.tv_category);
		tvDescription = (TextView) getView().findViewById(R.id.tv_description);
		etBudget = (EditText) getView().findViewById(R.id.et1);
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
	public void preLoadData() {
		mCategories = new CategoryTableAdapter(getActivity())
				.getAllCategory((Integer) TravelPrefs.getData(getActivity(),
						TravelPrefs.PREF_USER_ID));
		if (mCategories != null)
			tvCategory.setText(mCategories.get(mCurCategory).getNameCate());
		else
			tvCategory.setText(getString(R.string.loading));
	}

	@Override
	public void onClick(View v) {
		MainActivity mother = (MainActivity) getActivity();
		switch (v.getId()) {
		case R.id.btn1:
			if (mCategories != null)
				previousCat();
			break;
		case R.id.btn2:
			if (mCategories != null)
				nextCat();
			break;
		case R.id.btn_save:
			String description = tvDescription.getText() + "";
			float budget;
			try {
				budget = Float
						.valueOf(etBudget.getText().toString().split(" ")[1]);
				if (budget <= 0)
					throw new Exception();
			} catch (Exception e) {
				Toast.makeText(mother,
						getString(R.string.toast_invalid_budget),
						Toast.LENGTH_SHORT).show();
				break;
			}
			if (description.length() == 0) {
				Toast.makeText(mother,
						getString(R.string.toast_blank_description),
						Toast.LENGTH_SHORT).show();
			} else if (description.length() > 0 && mCategories != null) {
				int userId = (Integer) TravelPrefs.getData(getActivity(),
						TravelPrefs.PREF_USER_ID);
				SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd",
						Locale.ENGLISH);
				Calendar cal = Calendar.getInstance();
				String date = sdf.format(cal.getTime());
				Expense expense = new Expense(mCategories.get(mCurCategory)
						.getId(), tvDescription.getText().toString(), budget,
						date, userId);
				expense.setLocalCateId(mCategories.get(mCurCategory)
						.getLocalId());
				new ExpenseTableAdapter(mother).addExpense(expense, userId, 0,
						ContentProviderDB.FLAG_ADD);
				ExpensesFragment.syncExpenseCategories(mother);
				mother.changeScreen(Screen.EXPENSES);
			}
			break;
		case R.id.btnadd:
			new EditCategoriesDialog(getActivity(),
					new EditCategoriesDialog.EditCategoryCallBack() {

						@Override
						public void onSuccess(Category category) {
							mCategories.add(category);
						}

						@Override
						public void onDelete(Category category) {

						}
					}).show();
			break;
		case R.id.tv_category:
			if (mCategories.get(mCurCategory).getUserId() > 0)
				new EditCategoriesDialog(getActivity(),
						mCategories.get(mCurCategory),
						new EditCategoriesDialog.EditCategoryCallBack() {

							@Override
							public void onSuccess(Category category) {
								mCategories.set(mCurCategory, category);
								tvCategory.setText(category.getNameCate());
							}

							@Override
							public void onDelete(Category category) {
								mCategories.remove(category);
								nextCat();
							}
						}).show();
			break;
		default:
			break;
		}
	}

	private void nextCat() {
		if (mCurCategory < mCategories.size() - 1) {
			mCurCategory++;
		} else {
			mCurCategory = 0;
		}
		tvCategory.setText(mCategories.get(mCurCategory).getNameCate());
		if (mCategories.get(mCurCategory).getUserId() == 0) {
			tvCategory.setTextColor(defaultColor);
		} else {
			tvCategory.setTextColor(editableColor);
		}
	}

	private void previousCat() {
		if (mCurCategory > 0) {
			mCurCategory--;
		} else {
			mCurCategory = mCategories.size() - 1;
		}
		tvCategory.setText(mCategories.get(mCurCategory).getNameCate());
		if (mCategories.get(mCurCategory).getUserId() == 0) {
			tvCategory.setTextColor(defaultColor);
		} else {
			tvCategory.setTextColor(editableColor);
		}
	}
}
