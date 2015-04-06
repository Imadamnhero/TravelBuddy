package sdc.ui.adapter;

import java.util.List;

import sdc.data.Expense;
import sdc.data.database.adapter.ExpenseTableAdapter;
import sdc.travelapp.R;
import sdc.ui.fragment.ExpensesFragment;
import sdc.ui.travelapp.MainActivity;
import sdc.ui.utils.DateTimeUtils;
import sdc.ui.utils.StringUtils;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

public class ListChildExpensesAdapter extends BaseArrayAdapter<Expense> {
	private boolean isShowData = false;
	private int mColor;
	private MainActivity mContext;

	public ListChildExpensesAdapter(MainActivity context, List<Expense> data,
			int color) {
		super(context, R.layout.row_expandable_child, data);
		mColor = color;
		mContext = context;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		convertView = super.getView(position, convertView, parent);
		if (position % 2 == 0)
			convertView.findViewById(R.id.front).setBackgroundColor(
					getContext().getResources().getColor(
							R.color.expandable_black));
		else
			convertView.findViewById(R.id.front).setBackgroundColor(
					getContext().getResources().getColor(
							R.color.expandable_gray));
		convertView.findViewById(R.id.line).setBackgroundColor(mColor);
		TextView text1 = (TextView) convertView.findViewById(R.id.textView1);
		TextView text2 = (TextView) convertView.findViewById(R.id.textView2);
		TextView text3 = (TextView) convertView.findViewById(R.id.textView3);
		Expense expense = getItem(position);
		text1.setText(expense.getItem());
		text2.setText("$ "
				+ StringUtils.sExpensiveNumberFormat.format(expense.getMoney()));
		text3.setText(DateTimeUtils.formatDateForExpense(expense.getDate()));
		return convertView;
	}

	public void showData() {
		isShowData = true;
		notifyDataSetChanged();
	}

	public void hideData() {
		isShowData = false;
		notifyDataSetChanged();
	}

	@Override
	public int getCount() {
		if (isShowData)
			return super.getCount();
		else
			return 0;
	}

	@Override
	public void remove(Expense object) {
		super.remove(object);
		new ExpenseTableAdapter(mContext).deleteOfflineUponId(object.getId());
		ExpensesFragment.syncExpenseCategories((MainActivity) mContext);
		mContext.reloadCurFragment();
	}
}
