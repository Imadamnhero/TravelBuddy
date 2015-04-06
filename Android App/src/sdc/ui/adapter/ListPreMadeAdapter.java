package sdc.ui.adapter;

import java.util.List;

import sdc.data.Packing;
import sdc.travelapp.R;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.RadioButton;

public class ListPreMadeAdapter extends ArrayAdapter<Packing> {
	List<Packing> mData;
	int mSelectingItem = -1;

	public ListPreMadeAdapter(Context context, List<Packing> data) {
		super(context, R.layout.row_premade_item, data);
		this.mData = data;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		LayoutInflater inflater = LayoutInflater.from(getContext());
		convertView = inflater
				.inflate(R.layout.row_premade_item, parent, false);
		if (position == mData.size() - 1) {
			convertView.setBackgroundResource(R.drawable.bg_row_has_corner);
		}
		RadioButton rb = (RadioButton) convertView.findViewById(R.id.radio1);
		rb.setTag(position);
		rb.setChecked(position == mSelectingItem);
		rb.setText(mData.get(position).getTitle());
		rb.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				setSelectItem((Integer) v.getTag());
			}
		});
		return convertView;
	}

	public void setSelectItem(int position) {
		mSelectingItem = position;
		notifyDataSetChanged();
	}
}
