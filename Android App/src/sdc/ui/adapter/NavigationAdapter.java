package sdc.ui.adapter;

import sdc.travelapp.R;
import android.content.Context;
import android.content.res.ColorStateList;
import android.content.res.XmlResourceParser;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.TextView;

public class NavigationAdapter extends ArrayAdapter<String> {
	private static final int[] mImageData = { R.drawable.ic_home,
			R.drawable.ic_account2, R.drawable.ic_addphoto,
			R.drawable.ic_takephoto, R.drawable.ic_notes,
			R.drawable.ic_expenses, R.drawable.ic_packing, R.drawable.ic_alert,
			R.drawable.ic_slideshow, R.drawable.ic_group,
			R.drawable.ic_receipt, };
	private static final int[] mImageSelectedData = {
			R.drawable.menu_home_select, R.drawable.menu_acc_select,
			R.drawable.menu_addphoto_select, R.drawable.menu_takephoto_select,
			R.drawable.menu_notes_select, R.drawable.menu_expenses_select,
			R.drawable.menu_packing_select, R.drawable.menu_alert_select,
			R.drawable.menu_slideshow_select, R.drawable.menu_group_select,
			R.drawable.menu_receipts_select };
	private String[] mData;
	private Context mContext;
	private int mSelectedPosition;

	public NavigationAdapter(Context context) {
		super(context, R.layout.row_navigation, context.getResources()
				.getStringArray(R.array.arr_menu));
		this.mContext = context;
		this.mData = context.getResources().getStringArray(R.array.arr_menu);
		mSelectedPosition = 0;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		if (convertView == null) {
			LayoutInflater inflater = LayoutInflater.from(mContext);
			convertView = inflater.inflate(R.layout.row_navigation, parent,
					false);
		}
		TextView tv = (TextView) convertView.findViewById(R.id.textView1);
		ImageView img = (ImageView) convertView.findViewById(R.id.imageView1);
		tv.setText(mData[position]);
		img.setImageResource(mImageData[position]);
		if (mSelectedPosition == position) {
			tv.setTextColor(getContext().getResources().getColor(
					R.color.text_blue_color));
			img.setImageResource(mImageSelectedData[position]);
		} else {
			try {
				XmlResourceParser parser = getContext().getResources().getXml(
						R.drawable.menu_item_text_selector);
				ColorStateList colors = ColorStateList.createFromXml(
						getContext().getResources(), parser);
				tv.setTextColor(colors);
			} catch (Exception e) {
			}
			img.setImageResource(mImageData[position]);
		}
		return convertView;
	}

	public void setSelectedPosition(int position) {
		mSelectedPosition = position;
		notifyDataSetChanged();
	}
}
