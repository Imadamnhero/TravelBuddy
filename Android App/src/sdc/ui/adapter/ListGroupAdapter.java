package sdc.ui.adapter;

import java.util.List;

import sdc.data.User;
import sdc.net.webservice.BaseWS;
import sdc.travelapp.R;
import android.content.Context;
import android.util.Pair;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.assist.ImageScaleType;

public class ListGroupAdapter extends ArrayAdapter<Pair<User, Boolean>> {
	private DisplayImageOptions options = new DisplayImageOptions.Builder()
			.cacheInMemory(true).cacheOnDisc(true)
			.imageScaleType(ImageScaleType.IN_SAMPLE_POWER_OF_2)
			.showImageOnLoading(R.drawable.default_avatar)
			.showImageOnFail(R.drawable.default_avatar).build();

	public ListGroupAdapter(Context context, List<Pair<User, Boolean>> data) {
		super(context, R.layout.row_list_group, data);
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		LayoutInflater inflater = LayoutInflater.from(getContext());
		convertView = inflater.inflate(R.layout.row_list_group, parent, false);
		if (getCount() - 1 == position) {
			convertView.findViewById(R.id.front).setBackgroundResource(
					R.drawable.bg_row_has_corner);
			convertView.findViewById(R.id.back).setBackgroundResource(
					R.drawable.bg_row_deleting_corner);
		}
		ImageView imageFr = (ImageView) convertView
				.findViewById(R.id.img_group2);
		TextView nameFr = (TextView) convertView.findViewById(R.id.textView1);
		/*
		 * ImageLoader.getInstance().displayImage(
		 * getItem(position).first.getAvatar(), imageFr);
		 */
		nameFr.setText(getItem(position).first.getName());
		ImageLoader.getInstance().displayImage(
				BaseWS.HOST + getItem(position).first.getAvatar(), imageFr,
				options);
		return convertView;
	}

}
