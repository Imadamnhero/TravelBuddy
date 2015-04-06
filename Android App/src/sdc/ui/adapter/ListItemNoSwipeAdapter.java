package sdc.ui.adapter;

import java.util.List;

import sdc.data.PackingItem;
import sdc.travelapp.R;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.TextView;

public class ListItemNoSwipeAdapter extends ArrayAdapter<PackingItem> {
	private List<PackingItem> mData;

	public ListItemNoSwipeAdapter(Context context, List<PackingItem> data) {
		super(context, R.layout.row_listitem_noswipe, data);
		mData = data;
	}

	@Override
	public View getView(final int position, View convertView, ViewGroup parent) {
		if (convertView == null) {
			LayoutInflater inflater = LayoutInflater.from(getContext());
			convertView = inflater.inflate(R.layout.row_listitem_noswipe,
					parent, false);
		}
		CheckBox checkbox = (CheckBox) convertView.findViewById(R.id.cb1);
		TextView text = (TextView) convertView.findViewById(R.id.textView1);
		checkbox.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {

			@Override
			public void onCheckedChanged(CompoundButton buttonView,
					boolean isChecked) {

			}
		});
		
		checkbox.setChecked(mData.get(position).isCheck());
		checkbox.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {

			@Override
			public void onCheckedChanged(CompoundButton buttonView,
					boolean isChecked) {
				PackingItem curItem = mData.get(position);
				curItem.setCheck(!curItem.isCheck());
			}
		});
		text.setText(mData.get(position).getItem());
		convertView.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View v) {
				PackingItem curItem = mData.get(position);
				curItem.setCheck(!curItem.isCheck());
				notifyDataSetChanged();
			}
		});
		return convertView;
	}
}
