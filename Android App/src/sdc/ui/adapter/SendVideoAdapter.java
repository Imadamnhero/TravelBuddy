package sdc.ui.adapter;

import java.util.List;

import sdc.travelapp.R;
import android.content.Context;
import android.graphics.Bitmap;
import android.media.ThumbnailUtils;
import android.provider.MediaStore;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

public class SendVideoAdapter extends BaseAdapter {
	private Context mContext;
	private List<String> mData;

	public SendVideoAdapter(Context c, List<String> data) {
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
			grid = inflater.inflate(R.layout.cell_create_slideshow, parent,
					false);
			holder = new HolderView();
			holder.textView = (TextView) grid.findViewById(R.id.tv_description);
			holder.imageView = (ImageView) grid.findViewById(R.id.img);
			holder.tickIcon = (ImageView) grid.findViewById(R.id.tick_icon);
			grid.setTag(holder);

			String path = mData.get(position);
			String[] splitPath = path.split("/");
			holder.textView.setText(splitPath[splitPath.length -1]);
			Bitmap myBitmap = ThumbnailUtils.createVideoThumbnail(path,
					MediaStore.Video.Thumbnails.FULL_SCREEN_KIND);
			if (myBitmap == null) {
				holder.imageView.setBackgroundResource(R.drawable.home_bg);
			} else {
				holder.imageView.setImageBitmap(myBitmap);
			}
			holder.imageView.setOnClickListener(new OnImageClickListener(position,
					holder));
		} else {
			grid = (View) convertView;
			holder = (HolderView) grid.getTag();
		}
		return grid;
	}

	static class HolderView {
		TextView textView;
		ImageView imageView;
		ImageView tickIcon;
	}

	class OnImageClickListener implements OnClickListener {
		private int mPosition;
		private HolderView mHolder;

		// constructor
		public OnImageClickListener(int position, HolderView holder) {
			this.mPosition = position;
			this.mHolder = holder;
		}

		@Override
		public void onClick(View v) {
			if (mHolder.tickIcon.getVisibility() != View.VISIBLE) {
				mHolder.tickIcon.setVisibility(View.VISIBLE);
			} else {
				mHolder.tickIcon.setVisibility(View.GONE);
			}
		}

	}

}
