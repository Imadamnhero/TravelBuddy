package sdc.ui.adapter;

import java.io.File;
import java.util.List;

import sdc.application.TravelPrefs;
import sdc.data.Photo;
import sdc.data.database.adapter.PhotoTableAdapter;
import sdc.net.webservice.BaseWS;
import sdc.net.webservice.SyncPhotosWS;
import sdc.travelapp.R;
import sdc.ui.activity.FullScreenViewActivity2;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
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
import com.nostra13.universalimageloader.core.assist.FailReason;
import com.nostra13.universalimageloader.core.assist.ImageScaleType;
import com.nostra13.universalimageloader.core.assist.SimpleImageLoadingListener;

public class ListReceiptAdapter extends BaseAdapter {
	private DisplayImageOptions optionsNetwork = new DisplayImageOptions.Builder()
			.cacheOnDisc(true).showImageOnLoading(R.drawable.bg_img_default)
			.cacheInMemory(true).considerExifParams(true)
			.imageScaleType(ImageScaleType.IN_SAMPLE_POWER_OF_2)
			.showImageForEmptyUri(R.drawable.bg_img_default)
			.resetViewBeforeLoading(true)
			.showImageOnFail(R.drawable.bg_img_default).build();
	private DisplayImageOptions optionsLocal = new DisplayImageOptions.Builder()
			.considerExifParams(true).cacheInMemory(true)
			.imageScaleType(ImageScaleType.IN_SAMPLE_POWER_OF_2)
			.showImageOnLoading(R.drawable.bg_img_default).cacheInMemory(false)
			.showImageOnFail(R.drawable.bg_img_default).build();
	List<Photo> mData;
	private Context mContext;
	private View mInstructionLayout;

	public ListReceiptAdapter(Context context, List<Photo> data, View layout) {
		this.mData = data;
		mContext = context;
		mInstructionLayout = layout;
	}

	@Override
	public void notifyDataSetChanged() {
		if (mInstructionLayout != null) {
			if (mData != null) {
				boolean isAllSynchronized = true;
				for (Photo photo : mData) {
					if (photo.getServerId() == 0) {
						isAllSynchronized = false;
						break;
					}
				}
				if (isAllSynchronized) {
					mInstructionLayout.setVisibility(View.GONE);
				} else {
					mInstructionLayout.setVisibility(View.VISIBLE);
				}
			}
		}
		super.notifyDataSetChanged();
	}

	@Override
	public View getView(final int position, View convertView, ViewGroup parent) {
		HolderView holderView;
		if (convertView == null) {
			LayoutInflater inflater = LayoutInflater.from(mContext);
			convertView = inflater.inflate(R.layout.cell_image_receipt, parent,
					false);
			holderView = new HolderView();
			holderView.imageView = (ImageView) convertView
					.findViewById(R.id.img_receipt);
			holderView.date = (TextView) convertView
					.findViewById(R.id.tv_receipt_date);
			holderView.progressBar = (ProgressBar) convertView
					.findViewById(R.id.progressBar1);
			holderView.uploadIcon = (ImageView) convertView
					.findViewById(R.id.upload_icon);
			convertView.setTag(holderView);
		} else {
			holderView = (HolderView) convertView.getTag();
		}
		Photo receipt = mData.get(position);
		holderView.date.setText(receipt.getCaption());
		if (mData.get(position).getServerId() <= 0) {
			File imgFile = new File(receipt.getUrlImage());
			if (imgFile.exists()) {
				ImageLoader.getInstance().displayImage(
						"file://" + imgFile.getAbsolutePath(),
						holderView.imageView, optionsLocal,
						new SimpleImageLoadingListener() {
							@Override
							public void onLoadingComplete(String imageUri,
									View view, Bitmap loadedImage) {
								// TODO Auto-generated method stub
								super.onLoadingComplete(imageUri, view,
										loadedImage);
							}

							@Override
							public void onLoadingFailed(String imageUri,
									View view, FailReason failReason) {
								// TODO Auto-generated method stub
								super.onLoadingFailed(imageUri, view,
										failReason);
							}
						});
				holderView.uploadIcon.setVisibility(View.VISIBLE);
				// Utils.decodeSampledBitmapFromFile(file,100, 100);
			} else {
				// new
				// PhotoTableAdapter(mContext).deleteUponId(receipt.getId());
				// mData.remove(receipt);
				// this.notifyDataSetChanged();
			}
		} else {
			ImageLoader.getInstance().displayImage(
					BaseWS.HOST + receipt.getUrlImage(), holderView.imageView,
					optionsNetwork, new SimpleImageLoadingListener() {
						@Override
						public void onLoadingComplete(String imageUri,
								View view, Bitmap loadedImage) {
							// TODO Auto-generated method stub
							super.onLoadingComplete(imageUri, view, loadedImage);
						}
					});
			holderView.uploadIcon.setVisibility(View.GONE);
		}
		holderView.uploadIcon.setOnClickListener(new OnImageClickListener(
				position, holderView));
		holderView.imageView.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View v) {
				Intent i = new Intent(mContext, FullScreenViewActivity2.class);
				Photo photo = mData.get(position);
				i.putExtra("image", photo.getUrlImage());
				i.putExtra("date", photo.getCaption());
				i.putExtra("isLocal", photo.getServerId() == 0 ? true : false);
				i.putExtra("serverId", photo.getServerId());
				i.putExtra("clientId", photo.getId());
				mContext.startActivity(i);

			}
		});
		// check which photo is uploading
		if (SyncPhotosWS.checkIdIsUploading(receipt.getId())) {
			holderView.progressBar.setVisibility(View.VISIBLE);
			holderView.uploadIcon.setVisibility(View.GONE);
		} else {
			holderView.progressBar.setVisibility(View.GONE);
		}
		return convertView;
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

	static class HolderView {
		TextView date;
		ImageView imageView;
		ProgressBar progressBar;
		ImageView uploadIcon;
	}

	@Override
	public int getCount() {
		return mData.size();
	}

	class OnImageClickListener implements OnClickListener {
		private HolderView mHolder;
		private int mPosition;

		// constructor
		public OnImageClickListener(int position, HolderView holderView) {
			this.mPosition = position;
			this.mHolder = holderView;
		}

		@Override
		public void onClick(View v) {
			if (mHolder.uploadIcon.getVisibility() == View.VISIBLE) {
				SyncPhotosWS.fetchData(mContext, (Integer) TravelPrefs.getData(
						mContext, TravelPrefs.PREF_USER_ID),
						new PhotoTableAdapter(mContext)
								.getAPhotoByClientId(mData.get(mPosition)
										.getId()),
						new SyncPhotosWS.UploadCallBack() {

							@Override
							public void onSuccess(Photo photo) {
								// /notifyDataSetChanged();
							}

							@Override
							public void onFail(Photo photo, String reason) {
								// notifyDataSetChanged();
							}
						});
				mHolder.uploadIcon.setVisibility(View.GONE);
				mHolder.progressBar.setVisibility(View.VISIBLE);
			}
		}

	}

	public void add(Photo photo) {
		mData.add(photo);
	}

}
