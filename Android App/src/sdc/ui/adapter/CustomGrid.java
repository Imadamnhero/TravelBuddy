package sdc.ui.adapter;

import java.io.File;
import java.util.List;

import sdc.application.TravelPrefs;
import sdc.data.Photo;
import sdc.data.database.adapter.PhotoTableAdapter;
import sdc.net.webservice.BaseWS;
import sdc.net.webservice.SyncPhotosWS;
import sdc.travelapp.R;
import sdc.ui.activity.FullScreenViewActivity;
import android.content.Context;
import android.content.Intent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.assist.ImageScaleType;

public class CustomGrid extends BaseAdapter {
	private DisplayImageOptions optionsNetwork = new DisplayImageOptions.Builder()
			.cacheOnDisc(true).showImageOnLoading(R.drawable.home_bg)
			.considerExifParams(true).resetViewBeforeLoading(true)
			.cacheInMemory(true)
			.imageScaleType(ImageScaleType.IN_SAMPLE_POWER_OF_2)
			.showImageOnFail(R.drawable.home_bg).build();
	private DisplayImageOptions optionsLocal = new DisplayImageOptions.Builder()
			.considerExifParams(true).resetViewBeforeLoading(true)
			.showImageOnLoading(R.drawable.home_bg).cacheInMemory(true)
			.imageScaleType(ImageScaleType.IN_SAMPLE_POWER_OF_2)
			.showImageOnFail(R.drawable.home_bg).build();
	private Context mContext;
	private List<Photo> mData;
	private View mNodataLayout = null;
	private View mInstructionLayout = null;

	public CustomGrid(Context c, List<Photo> data) {
		mContext = c;
		mData = data;
	}

	public CustomGrid(Context c, List<Photo> data, View layoutNodata,
			View layoutInstruction) {
		mContext = c;
		mData = data;
		mNodataLayout = layoutNodata;
		mInstructionLayout = layoutInstruction;
		updateLayout();
	}

	private void updateLayout() {
		if (mInstructionLayout != null) {
			boolean isAllSynchronized = true;
			for (Photo photo : mData) {
				if (photo.getServerId() == 0) {
					isAllSynchronized = false;
					break;
				}
			}
			if (isAllSynchronized || mData.isEmpty()) {
				mInstructionLayout.setVisibility(View.GONE);
			} else {
				mInstructionLayout.setVisibility(View.VISIBLE);
			}
		}

		if (mNodataLayout != null) {
			if (mData.size() == 0) {
				mNodataLayout.setVisibility(View.VISIBLE);
			} else {
				mNodataLayout.setVisibility(View.GONE);
			}
		}
	}

	@Override
	public int getCount() {
		return mData.size();
	}

	@Override
	public Photo getItem(int position) {
		if (mData != null)
			return mData.get(position);
		else
			return null;
	}

	@Override
	public long getItemId(int position) {
		return mData.get(position).getId();
	}

	@Override
	public void notifyDataSetChanged() {
		updateLayout();
		super.notifyDataSetChanged();
	}

	@Override
	public View getView(final int position, View convertView, ViewGroup parent) {
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
			holder.progressBar = (ProgressBar) grid
					.findViewById(R.id.progressBar1);
			holder.uploadIcon = (ImageView) grid.findViewById(R.id.upload_icon);
			grid.setTag(holder);
		} else {
			grid = (View) convertView;
			holder = (HolderView) grid.getTag();
		}
		Photo photo = mData.get(position);
		holder.textView.setText(photo.getCaption());
		if (mData.get(position).getServerId() <= 0) {
			File imgFile = new File(photo.getUrlImage());
			if (imgFile.exists()) {
				ImageLoader.getInstance().displayImage(
						"file://" + imgFile.getAbsolutePath(),
						holder.imageView, optionsLocal);
				holder.uploadIcon.setVisibility(View.VISIBLE);
			} else {
				ImageLoader.getInstance().displayImage(photo.getUrlImage(),
						holder.imageView);
				holder.uploadIcon.setVisibility(View.VISIBLE);
			}

		} else {
			ImageLoader.getInstance().displayImage(
					BaseWS.HOST + photo.getUrlImage(), holder.imageView,
					optionsNetwork);
		}
		holder.uploadIcon.setOnClickListener(new OnImageClickListener(position,
				holder));
		holder.imageView.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View v) {
				Intent i = new Intent(mContext, FullScreenViewActivity.class);
				i.putExtra("position", position);
				mContext.startActivity(i);
			}
		});
		// check which photo is uploading
		if (SyncPhotosWS.checkIdIsUploading(photo.getId())) {
			holder.progressBar.setVisibility(View.VISIBLE);
			holder.uploadIcon.setVisibility(View.GONE);
		} else {
			holder.progressBar.setVisibility(View.GONE);
		}
		return grid;
	}

	static class HolderView {
		TextView textView;
		ImageView imageView;
		ProgressBar progressBar;
		ImageView uploadIcon;
	}

	class OnImageClickListener implements OnClickListener {
		private HolderView mHolder;
		private int mPosition;

		// constructor
		public OnImageClickListener(int position, HolderView holder) {
			this.mPosition = position;
			this.mHolder = holder;
		}

		@Override
		public void onClick(View v) {
			if (mHolder.uploadIcon.getVisibility() == View.VISIBLE) {
				SyncPhotosWS.fetchData(mContext, (Integer) TravelPrefs.getData(
						mContext, TravelPrefs.PREF_USER_ID),
						new PhotoTableAdapter(mContext)
								.getAPhotoByClientId(mData.get(mPosition)
										.getId()), null);
				mHolder.uploadIcon.setVisibility(View.GONE);
				mHolder.progressBar.setVisibility(View.VISIBLE);
			}
		}
	}
}