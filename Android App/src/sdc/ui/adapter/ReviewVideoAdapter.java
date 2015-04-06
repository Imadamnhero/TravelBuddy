package sdc.ui.adapter;

import java.io.File;
import java.util.List;

import sdc.data.SlideShow;
import sdc.travelapp.R;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.assist.ImageScaleType;

public class ReviewVideoAdapter extends BaseAdapter {
	private Context mContext;
	private List<SlideShow> mData;
	private DisplayImageOptions optionsNetwork = new DisplayImageOptions.Builder()
			.cacheOnDisc(true).showImageOnLoading(R.drawable.home_bg)
			.imageScaleType(ImageScaleType.IN_SAMPLE_POWER_OF_2)
			.considerExifParams(true).resetViewBeforeLoading(true)
			.showImageOnFail(R.drawable.home_bg).build();

	public ReviewVideoAdapter(Context c, List<SlideShow> data) {
		mContext = c;
		mData = data;
	}

	@Override
	public int getCount() {
		return mData.size();
	}

	@Override
	public Object getItem(int position) {
		if (mData != null)
			return mData.get(position);
		else
			return null;
	}

	@Override
	public long getItemId(int position) {
		return mData.hashCode();
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		View grid;
		HolderView holder;
		if (convertView == null) {
			LayoutInflater inflater = (LayoutInflater) mContext
					.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
			grid = new View(mContext);
			grid = inflater.inflate(R.layout.gridview, parent, false);
			holder = new HolderView();
			holder.textView = (TextView) grid.findViewById(R.id.tv_description);
			holder.imageView = (ImageView) grid.findViewById(R.id.img);
			holder.iconPlay = (ImageView) grid.findViewById(R.id.play_icon);
			holder.iconPlay.setVisibility(View.VISIBLE);
			grid.setTag(holder);
		} else {
			grid = (View) convertView;
			holder = (HolderView) grid.getTag();
		}
		SlideShow item = mData.get(position);
		File file = new File(item.getFilePath());
		holder.textView.setText(file.getName());
		ImageLoader.getInstance().displayImage(item.getThumbnail(),
				holder.imageView, optionsNetwork);

		// holder.imageView.setOnClickListener(new
		// OnImageClickListener(position));
		return grid;
	}

	static class HolderView {
		TextView textView;
		ImageView imageView;
		ImageView iconPlay;
	}

}
