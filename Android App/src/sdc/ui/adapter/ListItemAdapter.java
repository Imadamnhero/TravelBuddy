package sdc.ui.adapter;

import java.util.List;

import sdc.data.PackingItem;
import sdc.travelapp.R;
import android.content.Context;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CheckBox;
import android.widget.TextView;

public class ListItemAdapter extends BaseArrayAdapter<PackingItem> {

	public ListItemAdapter(Context context, List<PackingItem> data) {
		super(context, R.layout.row_list_item, data);
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		convertView = super.getView(position, convertView, parent);
		if (position == getCount() - 1) {
			convertView.findViewById(R.id.front).setBackgroundResource(
					R.drawable.bg_row_has_corner);
			convertView.findViewById(R.id.back).setBackgroundResource(
					R.drawable.bg_row_deleting_corner);
		}
		CheckBox checkbox = (CheckBox) convertView.findViewById(R.id.cb1);
		checkbox.setChecked(mData.get(position).isCheck());
		convertView.findViewById(R.id.clickview).setOnClickListener(
				new RowClickListener(position, checkbox));
		TextView textView = (TextView) convertView.findViewById(R.id.tv_item);
		String item = mData.get(position).getItem();
		textView.setText(item);
		return convertView;
	}

	private class RowClickListener implements View.OnClickListener {
		private int mPosition;
		private CheckBox mCheckbox;

		public RowClickListener(int pos, CheckBox cb) {
			mPosition = pos;
			mCheckbox = cb;
		}

		@Override
		public void onClick(View v) {
			PackingItem curItem = mData.get(mPosition);
			curItem.setCheck(!curItem.isCheck());
			mCheckbox.setChecked(curItem.isCheck());
		}
	}
}
