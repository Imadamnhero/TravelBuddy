package sdc.ui.fragment;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Locale;

import sdc.application.TravelPrefs;
import sdc.data.Category;
import sdc.data.Expense;
import sdc.data.database.ContentProviderDB;
import sdc.data.database.adapter.CategoryTableAdapter;
import sdc.data.database.adapter.ExpenseTableAdapter;
import sdc.data.database.adapter.TripTableAdapter;
import sdc.data.database.adapter.VersionTableAdapter;
import sdc.net.utils.JSONParseUtils;
import sdc.net.webservice.SyncCatergoriesWS;
import sdc.net.webservice.SyncExpensesWS;
import sdc.travelapp.R;
import sdc.ui.adapter.ListChildExpensesAdapter;
import sdc.ui.travelapp.MainActivity;
import sdc.ui.travelapp.MainActivity.Screen;
import sdc.ui.utils.SetupSwipeListViewUtils;
import sdc.ui.utils.StringUtils;
import sdc.ui.view.ChartPieView;
import android.annotation.SuppressLint;
import android.os.Bundle;
import android.util.Pair;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.fortysevendeg.swipelistview.SwipeListView;

public class ExpensesFragment extends BaseTripFragment {
	public static final String TITLE = "Expenses";
	private ChartPieView chartPie;
	private HashMap<Integer, List<Expense>> mListDataChild;
	private List<Float> mMoneyOfEachCategory;
	private List<Float> mPercentOfEachCategory;
	private double mTripBudget;
	private LinearLayout mExListView;
	private List<Category> mCategories;
	private MainActivity mContext;

	public ExpensesFragment() {
		super(TITLE);
	}

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
	}

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		View root = inflater.inflate(R.layout.fragment_expenses, container,
				false);
		return root;
	}

	@Override
	protected void addListener() {
		getView().findViewById(R.id.btnadd).setOnClickListener(
				new View.OnClickListener() {
					@Override
					public void onClick(View v) {
						((MainActivity) getActivity())
								.changeScreen(Screen.ADD_EXPENSES);
					}
				});
		super.addListener();
	}

	@Override
	protected void initComponents() {
		chartPie = (ChartPieView) getView().findViewById(R.id.chart_pie);
		mExListView = (LinearLayout) getView().findViewById(R.id.expandableLv);
	}

	@Override
	public void preLoadData() {
		mContext = (MainActivity) getActivity();
		mTripBudget = new TripTableAdapter(getActivity()).getTrip(
				mContext.getTripId(), mContext.getUserId()).getBudget();
		((TextView) getView().findViewById(R.id.tv_budget)).setText("$ "
				+ StringUtils.sExpensiveNumberFormat.format(mTripBudget));
		List<Expense> listExpenses = new ExpenseTableAdapter(mContext)
				.getExpenseOfUser(mContext.getUserId());
		List<Integer> listId = new ArrayList<Integer>();
		if (listExpenses != null)
			for (Expense expense : listExpenses) {
				int cateId = expense.getLocalCateId();
				if (!listId.contains(cateId))
					listId.add(cateId);
			}
		Collections.sort(listId);
		mCategories = new CategoryTableAdapter(mContext)
				.getCategoriesFromLocalCateIds(listId);
		initData(listExpenses);
		initExListView();
		List<Integer> colors = new ArrayList<Integer>();
		for (Category category : mCategories) {
			colors.add(category.getColor());
		}

		chartPie.setmListExpenses(mMoneyOfEachCategory, colors);
	}

	@SuppressLint("UseSparseArrays")
	private void initData(List<Expense> data) {
		this.mListDataChild = new HashMap<Integer, List<Expense>>();
		mMoneyOfEachCategory = new ArrayList<Float>();

		int i = 0;
		float sum = 0;
		float total = 0;
		while (i < mCategories.size()) {
			ArrayList<Expense> listExpenses = new ArrayList<Expense>();
			for (Expense expense : data) {
				if (expense.getLocalCateId() == mCategories.get(i).getId()) {
					listExpenses.add(expense);
					sum += expense.getMoney();
				}
			}
			mListDataChild.put(i, listExpenses);
			mMoneyOfEachCategory.add(sum);
			i++;
			total += sum;
			sum = 0;
		}
		mPercentOfEachCategory = new ArrayList<Float>();
		for (Float money : mMoneyOfEachCategory)
			mPercentOfEachCategory.add(money / total * 100);
		((TextView) getView().findViewById(R.id.tv_spent)).setText("$ "
				+ StringUtils.sExpensiveNumberFormat.format(total));
		((TextView) getView().findViewById(R.id.tv_remain)).setText("$ "
				+ StringUtils.sExpensiveNumberFormat
						.format(mTripBudget - total));
		ProgressBar bar = (ProgressBar) getView().findViewById(
				R.id.progress_bar);
		bar.setMax((int) mTripBudget);
		bar.setProgress((int) total);
	}

	private void initExListView() {
		mExListView.removeAllViews();
		LayoutInflater inflater = LayoutInflater.from(getActivity());
		for (int i = 0; i < mCategories.size(); i++) {
			ViewGroup group = (ViewGroup) inflater.inflate(
					R.layout.row_expandable_header, mExListView, false);
			TextView header = (TextView) group.findViewById(R.id.tv1);
			TextView percent = (TextView) group.findViewById(R.id.tv2);
			header.setText(mCategories.get(i).getNameCate());
			String strPercent = String.format(Locale.ENGLISH, "$ %s (%s%%)",
					StringUtils.sExpensiveNumberFormat
							.format(mMoneyOfEachCategory.get(i)),
					StringUtils.sExpensiveNumberFormat
							.format(mPercentOfEachCategory.get(i)));
			percent.setText(strPercent);
			group.findViewById(R.id.line).setBackgroundColor(
					mCategories.get(i).getColor());
			mExListView.addView(group);
			SwipeListView lvChild = createSwipeListView();
			lvChild.setAdapter(new ListChildExpensesAdapter(
					(MainActivity) getActivity(), mListDataChild.get(i),
					mCategories.get(i).getColor()));
			mExListView.addView(lvChild);
			// this must write i<<1 to save right position of group in
			// linearlayout
			group.setOnClickListener(new GroupClickListener(i << 1));
		}
	}

	private class GroupClickListener implements View.OnClickListener {
		int mPosition;
		boolean isOpen = false;

		public GroupClickListener(int pos) {
			mPosition = pos;
		}

		@Override
		public void onClick(View v) {
			ImageView dropdown = (ImageView) v.findViewById(R.id.dropdown);
			ListChildExpensesAdapter adapter = (ListChildExpensesAdapter) ((SwipeListView) mExListView
					.getChildAt(mPosition + 1)).getAdapter();
			if (isOpen) {
				dropdown.setImageResource(Expense.DEFAULT_DRAWABLE);
				adapter.hideData();
				isOpen = false;
			} else {
				// dropdown.setImageResource(mA.get(mPosition >> 1));
				adapter.showData();
				isOpen = true;
			}
		}
	}

	public SwipeListView createSwipeListView() {
		SwipeListView list = new SwipeListView(getActivity(), R.id.back,
				R.id.front);
		list.setDivider(null);
		SetupSwipeListViewUtils.setup(list, getActivity());
		return list;
	}

	// This Variable use to fix bug happen when slow connection, while a row is
	// uploading, user upload that row again which make data is duplicated
	private static List<Integer> sIdsUploading = new LinkedList<Integer>();

	public static void clearUploading(
			List<Pair<Integer, Integer>> listIdUploaded) {
		for (Pair<Integer, Integer> pair : listIdUploaded)
			sIdsUploading.remove(pair.first);
	}

	public static void syncExpenseData(MainActivity context) {
		SyncExpensesWS expensesWS = SyncExpensesWS.getInstance();
		if (!expensesWS.isLoading()) {
			int userId = (Integer) TravelPrefs.getData(context,
					TravelPrefs.PREF_USER_ID);
			int tripId = (Integer) TravelPrefs.getData(context,
					TravelPrefs.PREF_TRIP_ID);
			int expenseVer = new VersionTableAdapter(context)
					.getVersionTableofUser(userId,
							ContentProviderDB.COL_VERSION_EXPENSE);
			List<Expense> listExpense = new ExpenseTableAdapter(context)
					.getExpensesNeedUpload();
			if (listExpense != null)
				for (int i = 0; i < listExpense.size(); i++) {
					int id = listExpense.get(i).getId();
					boolean isRemove = false;
					for (int uploading : sIdsUploading) {
						if (uploading == id)
							isRemove = true;
					}
					if (isRemove) {
						listExpense.remove(i);
						i--;
					} else
						sIdsUploading.add(id);
				}
			expensesWS.fetchData(context, expenseVer, JSONParseUtils
					.convertExpensesToJSONArray(listExpense, tripId), userId);
		}
	}

	public static void syncExpenseCategories(MainActivity context) {
		SyncCatergoriesWS categoryWS = SyncCatergoriesWS.getInstance();
		if (!categoryWS.isLoading()
				&& !SyncExpensesWS.getInstance().isLoading()) {
			int userId = (Integer) TravelPrefs.getData(context,
					TravelPrefs.PREF_USER_ID);
			int categoryVersion = new VersionTableAdapter(context)
					.getVersionTableofUser(userId,
							ContentProviderDB.COL_VERSION_CATE);
			List<Category> listCategory = new CategoryTableAdapter(context)
					.getCategoriesNeedUpload();
			if (listCategory != null) {

			}

			categoryWS.fetchData(context, categoryVersion,
					JSONParseUtils.convertCategoriesToJSONArray(listCategory),
					userId);
		}
	}
}
