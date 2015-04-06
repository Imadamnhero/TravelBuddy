package sdc.ui.adapter;

import java.util.List;

import sdc.objects.CropOption;
import android.content.Context;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;

public class CropOptionAdapter extends ArrayAdapter<CropOption> {
	private int resourceID;
	private Context context;

	public CropOptionAdapter(Context context, int textViewResourceId,
			List<CropOption> objects) {
		super(context, textViewResourceId, objects);
		this.resourceID = textViewResourceId;
		this.context = context;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup group) {
		TextView tv;
		CropOption item = getItem(position);
		if (convertView == null) {
			tv = (TextView) View.inflate(context, resourceID, null);
		} else {
			tv = (TextView) convertView;
		}
		tv.setText(item.title);
		tv.setCompoundDrawablesWithIntrinsicBounds(item.icon, null, null, null);
		return tv;
	}
}