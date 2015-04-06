package sdc.ui.adapter;

import java.io.File;
import java.util.List;

import sdc.application.TravelPrefs;
import sdc.data.Photo;
import sdc.data.database.ContentProviderDB;
import sdc.data.database.adapter.PhotoTableAdapter;
import sdc.net.webservice.BaseWS;
import sdc.net.webservice.SyncPhotosWS;
import sdc.travelapp.R;
import sdc.ui.customview.CustomDialog;
import sdc.ui.view.TouchImageView;
import android.app.Activity;
import android.content.Context;
import android.graphics.drawable.ColorDrawable;
import android.support.v4.view.PagerAdapter;
import android.support.v4.view.ViewPager;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.assist.ImageScaleType;

public class FullScreenImageAdapter extends PagerAdapter {
	private List<Photo> mListPhoto;
	private Activity _activity;
	private LayoutInflater inflater;
	private OnRemovePhotoListener mListener;
	private int mUserId;
	private DisplayImageOptions optionsNetwork = new DisplayImageOptions.Builder()
			.cacheOnDisc(true).showImageOnLoading(R.drawable.home_bg)
			.cacheInMemory(false).considerExifParams(true)
			.imageScaleType(ImageScaleType.IN_SAMPLE_POWER_OF_2)
			.resetViewBeforeLoading(true).showImageOnFail(R.drawable.home_bg)
			.build();
	private DisplayImageOptions optionsLocal = new DisplayImageOptions.Builder()
			.considerExifParams(true).resetViewBeforeLoading(true)
			.imageScaleType(ImageScaleType.IN_SAMPLE_POWER_OF_2)
			.showImageOnLoading(R.drawable.home_bg).cacheInMemory(false)
			.showImageOnFail(R.drawable.home_bg).build();

	// constructor
	public FullScreenImageAdapter(Activity activity, List<Photo> listPhoto,
			OnRemovePhotoListener listener) {
		this.mListPhoto = listPhoto;
		_activity = activity;
		mListener = listener;
		mUserId = (Integer) TravelPrefs.getData(activity,
				TravelPrefs.PREF_USER_ID);
	}

	@Override
	public int getCount() {
		return mListPhoto.size();
	}

	@Override
	public boolean isViewFromObject(View view, Object object) {
		return view == ((RelativeLayout) object);
	}

	@Override
	public Object instantiateItem(ViewGroup container, int position) {
		TouchImageView imgDisplay;
		View btnClose;
		TextView tv_description;
		View btnDelete;
		inflater = (LayoutInflater) _activity
				.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		View viewLayout = inflater.inflate(R.layout.layout_fullscreen_image,
				container, false);
		tv_description = (TextView) viewLayout
				.findViewById(R.id.tv_description);
		
		imgDisplay = (TouchImageView) viewLayout.findViewById(R.id.imgDisplay);
		btnClose = (View) viewLayout.findViewById(R.id.btnClose);
		btnDelete = (View) viewLayout.findViewById(R.id.btnDelete);
		Photo photo = mListPhoto.get(position);
		if (photo.getServerId() <= 0) {
			File imgFile = new File(photo.getUrlImage());
			if (imgFile.exists()) {
				ImageLoader.getInstance().displayImage(
						"file://" + photo.getUrlImage(), imgDisplay,
						optionsLocal);
			} else {
				new PhotoTableAdapter(_activity).deleteUponId(photo.getId());
				mListPhoto.remove(photo);
				this.notifyDataSetChanged();
			}

		} else {
			ImageLoader.getInstance().displayImage(
					BaseWS.HOST + photo.getUrlImage(), imgDisplay,
					optionsNetwork);
		}
		if(photo.isReceipt()){
			tv_description.setVisibility(View.VISIBLE);
			tv_description.setText(photo.getCaption());
		}else{
			tv_description.setVisibility(View.GONE);
		}
		btnClose.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				_activity.finish();
			}
		});
		if (mUserId == photo.getOwnerId()) {
			btnDelete.setOnClickListener(new OnDeleteButtonClickListener(photo
					.getId(), photo.getServerId(), position));
			btnDelete.setVisibility(View.VISIBLE);
		} else {
			btnDelete.setVisibility(View.GONE);
		}

		((ViewPager) container).addView(viewLayout);
		return viewLayout;
	}

	@Override
	public void destroyItem(ViewGroup container, int position, Object object) {
		((ViewPager) container).removeView((RelativeLayout) object);

	}

	class OnDeleteButtonClickListener implements View.OnClickListener {
		private int idOfPhoto;
		private int mServerId;
		private int mPosition;

		public OnDeleteButtonClickListener(int id, int serverId, int pos) {
			this.idOfPhoto = id;
			this.mServerId = serverId;
			this.mPosition = pos;
		}

		@Override
		public void onClick(View v) {
			showDeleteDialog(idOfPhoto, mServerId, mPosition);
		}
	}

	class OnYesButtonClickListener implements CustomDialog.OnClickLeft {
		private int idOfPhoto;
		private int mServerId;
		private int mPosition;

		public OnYesButtonClickListener(int id, int serverId, int pos) {
			this.idOfPhoto = id;
			this.mServerId = serverId;
			this.mPosition = pos;
		}

		@Override
		public void click() {
			mListPhoto.remove(mPosition);
			// FullScreenImageAdapter.this.notifyDataSetChanged();
			if (mListener != null) {
				mListener.onRemoved();
			}
			new PhotoTableAdapter(_activity).deleteOfflineUponId(idOfPhoto);
			Photo photo = new Photo(idOfPhoto, (Integer) TravelPrefs.getData(
					_activity, TravelPrefs.PREF_USER_ID), mServerId,
					ContentProviderDB.FLAG_DEL);
			SyncPhotosWS.fetchData(_activity.getApplicationContext(),
					(Integer) TravelPrefs.getData(_activity,
							TravelPrefs.PREF_USER_ID), photo, null);
		}
	}

	protected void showDeleteDialog(int id, int serverId, int pos) {
		CustomDialog dialog = new CustomDialog(_activity,
				_activity.getString(R.string.choose_picture_title),
				_activity.getString(R.string.txt_confirm_delete_photo));
		dialog.getWindow().setBackgroundDrawable(
				new ColorDrawable(android.graphics.Color.TRANSPARENT));
		dialog.setOnClickLeft(new OnYesButtonClickListener(id, serverId, pos));
		dialog.setOnClickRight(new CustomDialog.OnClickRight() {

			@Override
			public void click() {
			}
		});
		dialog.show();
		dialog.setTextBtn(_activity.getString(R.string.btn_yes),
				_activity.getString(R.string.btn_no));
	}

	public interface OnRemovePhotoListener {
		public void onRemoved();
	}
}
