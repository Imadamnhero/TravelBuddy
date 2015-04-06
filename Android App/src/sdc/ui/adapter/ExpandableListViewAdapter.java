package sdc.ui.adapter;

import java.util.HashMap;
import java.util.List;

import sdc.data.Expense;
import sdc.travelapp.R;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseExpandableListAdapter;
import android.widget.TextView;

public class ExpandableListViewAdapter extends BaseExpandableListAdapter {
	private Context mContext;
	private String[] mListDataHeader;
	private int black, gray, purpil, blue, yellow, dropdown_color;
	private HashMap<Integer, List<Expense>> mListDataChild;

	public ExpandableListViewAdapter(Context context, String[] group,
			HashMap<Integer, List<Expense>> child) {
		this.mContext = context;
		this.mListDataHeader = group;
		this.mListDataChild = child;
		initColor(context);
	}

	private void initColor(Context context) {
		black = context.getResources().getColor(R.color.expandable_black);
		gray = context.getResources().getColor(R.color.expandable_gray);
		purpil = context.getResources().getColor(R.color.pie_purpil);
		blue = context.getResources().getColor(R.color.pie_blue);
		yellow = context.getResources().getColor(R.color.pie_yellow);
		dropdown_color = context.getResources().getColor(
				R.color.expandable_down);
	}

	private void changeViewColorBaseOnGroup(View v, int groupPosition) {
		switch (groupPosition) {
		case 0:
			v.setBackgroundColor(blue);
			break;
		case 1:
			v.setBackgroundColor(yellow);
			break;
		case 2:
			v.setBackgroundColor(purpil);
			break;
		default:
			break;
		}
	}

	@Override
	public Expense getChild(int groupPosition, int childPosititon) {
		return this.mListDataChild.get(groupPosition).get(childPosititon);
	}

	@Override
	public long getChildId(int groupPosition, int childPosition) {
		return childPosition;
	}

	@Override
	public View getChildView(int groupPosition, final int childPosition,
			boolean isLastChild, View convertView, ViewGroup parent) {
		final Expense child = getChild(groupPosition, childPosition);
		if (convertView == null) {
			LayoutInflater infalInflater = (LayoutInflater) this.mContext
					.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
			convertView = infalInflater.inflate(R.layout.row_expandable_child,
					parent, false);
		}
		TextView text1 = (TextView) convertView.findViewById(R.id.textView1);
		TextView text2 = (TextView) convertView.findViewById(R.id.textView2);
		TextView text3 = (TextView) convertView.findViewById(R.id.textView3);
		text1.setText(child.getItem());
		text2.setText("$ " + child.getMoney());
		text3.setText(child.getDate());
		if (childPosition % 2 == 0)
			convertView.setBackgroundColor(black);
		else
			convertView.setBackgroundColor(gray);
		changeViewColorBaseOnGroup(convertView.findViewById(R.id.line),
				groupPosition);
		return convertView;
	}

	@Override
	public int getChildrenCount(int groupPosition) {
		return mListDataChild.get(groupPosition).size();
	}

	@Override
	public Object getGroup(int groupPosition) {
		return mListDataHeader[groupPosition];
	}

	@Override
	public int getGroupCount() {
		return mListDataHeader.length;
	}

	@Override
	public long getGroupId(int groupPosition) {
		return groupPosition;
	}

	@Override
	public View getGroupView(int groupPosition, boolean isExpanded,
			View convertView, ViewGroup parent) {
		final String headerTitle = (String) getGroup(groupPosition);
		if (convertView == null) {
			LayoutInflater inflater = (LayoutInflater) this.mContext
					.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
			convertView = inflater.inflate(R.layout.row_expandable_header,
					parent, false);
		}
		TextView header = (TextView) convertView.findViewById(R.id.tv1);
		header.setText(headerTitle);
		changeViewColorBaseOnGroup(convertView.findViewById(R.id.line),
				groupPosition);
		return convertView;
	}

	@Override
	public boolean hasStableIds() {
		return false;
	}

	@Override
	public boolean isChildSelectable(int groupPosition, int childPosition) {
		return true;
	}

}
