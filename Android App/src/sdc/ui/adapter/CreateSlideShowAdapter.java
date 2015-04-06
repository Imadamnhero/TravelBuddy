package sdc.ui.adapter;

import java.io.File;
import java.util.List;

import sdc.data.Photo;
import sdc.data.database.adapter.PhotoTableAdapter;
import sdc.net.webservice.BaseWS;
import sdc.travelapp.R;
import sdc.ui.fragment.CreateSlideShowFragment;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.assist.ImageScaleType;

public class CreateSlideShowAdapter extends BaseAdapter {
	private DisplayImageOptions options = new DisplayImageOptions.Builder()
			.cacheInMemory(true).cacheOnDisc(true)
			.showImageOnLoading(R.drawable.home_bg)
			.imageScaleType(ImageScaleType.IN_SAMPLE_POWER_OF_2)
			.showImageOnFail(R.drawable.home_bg).build();
	private Context mContext;
	private List<Photo> mData;
	private int[] mSelectedPhotos;
	private CreateSlideShowFragment mCallBack;

	public CreateSlideShowAdapter(Context c, List<Photo> data,
			CreateSlideShowFragment callback) {
		mContext = c;
		mData = data;
		mCallBack = callback;
		mSelectedPhotos = new int[mData.size()];
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
		return mData.get(position).getId();
	}

	public void unTickAPhoto(int position) {
		mSelectedPhotos[position] = 0;
		notifyDataSetChanged();
	}

	public void unTickAllPhoto() {
		for (int i = 0; i < mSelectedPhotos.length; i++) {
			mSelectedPhotos[i] = 0;
		}
		notifyDataSetChanged();
	}

	public void reloadPhoto(List<Photo> photos) {
		mData.clear();
		mData.addAll(photos);
		mSelectedPhotos = new int[mData.size()];
		this.notifyDataSetChanged();
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
			holder.iconTick = (ImageView) grid.findViewById(R.id.tick_icon);
			grid.setTag(holder);
		} else {
			grid = (View) convertView;
			holder = (HolderView) grid.getTag();
		}
		Photo photo = mData.get(position);
		holder.textView.setText(photo.getCaption());
		if (mSelectedPhotos[position] == 0)
			holder.iconTick.setVisibility(View.GONE);
		else
			holder.iconTick.setVisibility(View.VISIBLE);
		if (mData.get(position).getServerId() <= 0) {
			File imgFile = new File(photo.getUrlImage());
			if (imgFile.exists()) {
				Bitmap myBitmap = BitmapFactory.decodeFile(imgFile
						.getAbsolutePath());
				holder.imageView.setImageBitmap(myBitmap);
			} else {
				new PhotoTableAdapter(mContext).deleteUponId(photo.getId());
				mData.remove(photo);
				this.notifyDataSetChanged();
			}
		} else {
			ImageLoader.getInstance().displayImage(
					BaseWS.HOST + photo.getUrlImage(), holder.imageView,
					options);
		}
		holder.imageView.setOnClickListener(new OnImageClickListener(position,
				holder));
		return grid;
	}

	static class HolderView {
		TextView textView;
		ImageView imageView;
		ImageView iconTick;
	}

	class OnImageClickListener implements OnClickListener {
		private HolderView mHolder;
		private int mPosition;

		public OnImageClickListener(int position, HolderView holder) {
			this.mPosition = position;
			this.mHolder = holder;
		}

		@Override
		public void onClick(View v) {
			if (mHolder.iconTick.getVisibility() != View.VISIBLE) {
				mHolder.iconTick.setVisibility(View.VISIBLE);
				mSelectedPhotos[mPosition] = 1;
				mCallBack.addPhotoToClip(mPosition);
			} else {
				mHolder.iconTick.setVisibility(View.GONE);
				mSelectedPhotos[mPosition] = 0;
				mCallBack.removePhotoToClip(mPosition);
			}
		}

	}
}
