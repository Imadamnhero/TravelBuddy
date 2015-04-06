package sdc.ui.fragment;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import sdc.application.TravelPrefs;
import sdc.data.Photo;
import sdc.data.database.adapter.PhotoTableAdapter;
import sdc.net.webservice.BaseWS;
import sdc.net.webservice.CreateSlideShowWS;
import sdc.net.webservice.task.DownloadFileFromURLTask;
import sdc.travelapp.R;
import sdc.ui.activity.SlideShowActivity;
import sdc.ui.adapter.CreateSlideShowAdapter;
import sdc.ui.travelapp.MainActivity;
import sdc.ui.utils.DateTimeUtils;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.Bitmap.Config;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.GridView;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListAdapter;
import android.widget.TextView;

import com.nikmesoft.nmsharekit.NMShareKit;
import com.nikmesoft.nmsharekit.objects.NMShareMessage;
import com.nikmesoft.nmsharekit.objects.NMShareMessage.NMShareType;
import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.assist.ImageScaleType;

public class CreateSlideShowFragment extends BaseTripFragment implements
		View.OnClickListener {
	public static final String TITLE = "Create Slideshow";
	private CreateSlideShowAdapter mGridAdapter;
	private LinearLayout mFramesView;
	private TextView tvTimeOfVideo;
	private TextView tvChossenMusic;
	private List<Photo> mListPhoto;
	private List<Photo> mListChoosenPhoto;
	private String mMusicPath;
	private MainActivity mContext;
	public static final int PICK_MUSIC = 35;
	private String mVideoUrl;
	private AlertDialog.Builder mActionDialog;
	private String mUrlThumbnail = null;
	private TextView mTvInstruction;

	public CreateSlideShowFragment() {
		super(TITLE);
	}

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		View root = inflater.inflate(R.layout.fragment_create_slideshow,
				container, false);
		mContext = (MainActivity) getActivity();
		return root;
	}

	@Override
	protected void initComponents() {
		mListPhoto = new ArrayList<Photo>();
		mListChoosenPhoto = new ArrayList<Photo>();
		mFramesView = (LinearLayout) getView().findViewById(R.id.frames);
		mGridAdapter = new CreateSlideShowAdapter(getActivity(), mListPhoto,
				this);
		mTvInstruction = (TextView) getView().findViewById(R.id.tv_instruction);
		((GridView) getView().findViewById(R.id.gridview))
				.setAdapter(mGridAdapter);
		tvTimeOfVideo = (TextView) getView().findViewById(R.id.btn_timeplay);
		tvChossenMusic = (TextView) getView().findViewById(R.id.btn_music);
		initDialogAction();
	}

	@Override
	public void preLoadData() {
		mGridAdapter.reloadPhoto(new PhotoTableAdapter(mContext)
				.getSynchronizedPhotoOfTrip(mContext.getTripId()));
		if (mGridAdapter.getCount() == 0) {
			getView().findViewById(R.id.tv_no_data).setVisibility(View.VISIBLE);
		}
	}

	@Override
	protected void addListener() {
		super.addListener();
		getView().findViewById(R.id.title_btn_menu).setOnClickListener(this);
		getView().findViewById(R.id.btn_share).setOnClickListener(this);
		getView().findViewById(R.id.btn_play).setOnClickListener(this);
		getView().findViewById(R.id.btn_download).setOnClickListener(this);
		tvChossenMusic.setOnClickListener(this);
	}

	@Override
	public void onClick(View v) {
		switch (v.getId()) {
		case R.id.title_btn_menu:
			getActivity().onBackPressed();
			break;
		case R.id.btn_share:
			mActionDialog.show();
			break;
		case R.id.btn_download:
			if (TextUtils.isEmpty(mVideoUrl))
				mContext.showToast(getString(R.string.toast_create_first));
			else
				new DownloadFileFromURLTask(mContext).execute(mVideoUrl);
			break;
		case R.id.btn_play:
			if (mListChoosenPhoto.size() >= 2 /* && !TextUtils.isEmpty(mMusicPath) */) {
				mUrlThumbnail = BaseWS.HOST
						+ mListChoosenPhoto.get(0).getUrlImage();
				String strListPhotos = "";
				for (int i = 0; i < mListChoosenPhoto.size(); i++) {
					if (i == mListChoosenPhoto.size() - 1)
						strListPhotos += String.valueOf(mListChoosenPhoto
								.get(i).getServerId());
					else
						strListPhotos += String.valueOf(mListChoosenPhoto
								.get(i).getServerId()) + ",";
				}
				new CreateSlideShowWS(mContext, this).fetchData(
						mContext.getUserId(), mContext.getTripId(),
						strListPhotos, mMusicPath);
			} else
				mContext.showToast(getString(R.string.toast_valid_createvideo));

			break;
		case R.id.btn_music:
			Intent intent = new Intent();
			intent.setAction(Intent.ACTION_GET_CONTENT);
			intent.setType("audio/mp3");
			startActivityForResult(intent, PICK_MUSIC);
			break;
		}
	}

	public void addPhotoToClip(int pos) {
		if (mFramesView != null) {
			mListChoosenPhoto.add(mListPhoto.get(pos));
			LayoutInflater inflater = (LayoutInflater) mContext
					.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
			View view = inflater.inflate(R.layout.cell_frame_slideshow,
					mFramesView, false);
			ImageView image = (ImageView) view.findViewById(R.id.squareImage1);
			ImageView btnDel = (ImageView) view.findViewById(R.id.imageView1);
			btnDel.setOnClickListener(new onClickDeletePhoto(pos));
			if (mListPhoto.get(pos).getServerId() <= 0) {
				File imgFile = new File(mListPhoto.get(pos).getUrlImage());
				if (imgFile.exists()) {
					ImageLoader
							.getInstance()
							.displayImage(
									"file://"
											+ mListPhoto.get(pos).getUrlImage(),
									image,
									new DisplayImageOptions.Builder()
											.bitmapConfig(Config.RGB_565)
											.imageScaleType(
													ImageScaleType.IN_SAMPLE_POWER_OF_2)
											.build());
				}
			} else {
				ImageLoader.getInstance().displayImage(
						BaseWS.HOST + mListPhoto.get(pos).getUrlImage(),
						image,
						new DisplayImageOptions.Builder()
								.bitmapConfig(Config.RGB_565)
								.imageScaleType(
										ImageScaleType.IN_SAMPLE_POWER_OF_2)
								.build());
			}
			mFramesView.addView(view);
			tvTimeOfVideo.setText(DateTimeUtils
					.increaseTimeOfVideo(tvTimeOfVideo.getText().toString()));
			if (mListChoosenPhoto.isEmpty()) {
				mTvInstruction.setVisibility(View.VISIBLE);
			} else {
				mTvInstruction.setVisibility(View.GONE);
			}
		}
	}

	public void removePhotoToClip(int pos) {
		int id = mListPhoto.get(pos).getId();
		for (int i = 0; i < mListChoosenPhoto.size(); i++) {
			if (mListChoosenPhoto.get(i).getId() == id) {
				mFramesView.removeViewAt(i);
				mListChoosenPhoto.remove(i);
				tvTimeOfVideo
						.setText(DateTimeUtils
								.decreaseTimeOfVideo(tvTimeOfVideo.getText()
										.toString()));
			}
		}
		if (mListChoosenPhoto.isEmpty()) {
			mTvInstruction.setVisibility(View.VISIBLE);
		} else {
			mTvInstruction.setVisibility(View.GONE);
		}
	}

	public class onClickDeletePhoto implements View.OnClickListener {
		private int mPosition;

		public onClickDeletePhoto(int position) {
			mPosition = position;
		}

		@Override
		public void onClick(View v) {
			mGridAdapter.unTickAPhoto(mPosition);
			removePhotoToClip(mPosition);
			if (mListChoosenPhoto.isEmpty()) {
				mTvInstruction.setVisibility(View.VISIBLE);
			} else {
				mTvInstruction.setVisibility(View.GONE);
			}
		}
	}

	@Override
	public void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);
		switch (requestCode) {
		case PICK_MUSIC:
			if (resultCode == Activity.RESULT_OK) {
				Uri musicURi = data.getData();
				if (musicURi.toString().startsWith("file:///")) {
					mMusicPath = musicURi.toString().replaceAll("%20", " ")
							.replace("file:///", "");
				} else {
					try {
						mMusicPath = getRealPathFromURI(musicURi).replace(
								"%20", " ");

					} catch (NullPointerException e) {
						e.printStackTrace();
						mContext.showToast(getString(R.string.toast_invalid_audio));
						tvChossenMusic.setText("No Audio");
					}
				}
				if (mMusicPath != null && new File(mMusicPath).exists()) {
					String fileName = mMusicPath.substring(mMusicPath
							.lastIndexOf("/") + 1);
					String[] splitName = fileName.split("\\.");
					if (splitName[splitName.length - 1].equals("mp3")) {
						tvChossenMusic.setText(fileName);
					} else {
						mContext.showToast(getString(R.string.toast_invalid_audio));
						tvChossenMusic.setText("No Audio");
					}
				}
			}
		}
	}

	public void setVideoURl(String url) {
		this.mVideoUrl = url;
		// mTvInstruction.setText(R.string.txt_instruction_download_slideshow);
		mFramesView.removeAllViews();
		mListChoosenPhoto.clear();
		mGridAdapter.unTickAllPhoto();
		mTvInstruction.setVisibility(View.VISIBLE);

		Intent playVideoIntent = new Intent(mContext, SlideShowActivity.class);
		playVideoIntent.putExtra("video", url);
		playVideoIntent.putExtra("thumbnail", mUrlThumbnail);
		mContext.startActivity(playVideoIntent);
	}

	public static boolean deleteDir(File dir) {
		if (dir.isDirectory()) {
			String[] children = dir.list();
			for (int i = 0; i < children.length; i++) {
				boolean success = deleteDir(new File(dir, children[i]));
				if (!success) {
					return false;
				}
			}
		}
		return dir.delete();
	}

	public static boolean createDir(File dir) {
		boolean success = true;
		if (!dir.exists()) {
			success = dir.mkdir();
		}
		return success;
	}

	public String getRealPathFromURI(Uri contentUri) {
		// can post image
		String[] proj = { MediaStore.Images.Media.DATA };
		Cursor cursor = getActivity().getContentResolver().query(contentUri,
				proj, // Which
				// columns
				// to
				// return
				null, // WHERE clause; which rows to return (all rows)
				null, // WHERE clause selection arguments (none)
				null); // Order-by clause (ascending by name)
		int column_index = cursor
				.getColumnIndexOrThrow(MediaStore.Images.Media.DATA);
		cursor.moveToFirst();
		return cursor.getString(column_index);
	}

	public class Item {
		public final String text;
		public final String icon;

		public Item(String text, String icon) {
			this.text = text;
			this.icon = icon;
		}

		@Override
		public String toString() {
			return text;
		}
	}

	public void initDialogAction() {
		String[] title = getResources().getStringArray(
				R.array.arr_share_slideshow);
		String[] icon = getResources().getStringArray(
				R.array.arr_share_slideshow_ic);
		final Item[] items = new Item[title.length];
		for (int i = 0; i < title.length; i++)
			items[i] = new Item(title[i], icon[i]);
		ListAdapter adapter = new ArrayAdapter<Item>(mContext,
				android.R.layout.select_dialog_item, android.R.id.text1, items) {
			public View getView(int position, View convertView, ViewGroup parent) {
				View v = super.getView(position, convertView, parent);
				TextView tv = (TextView) v.findViewById(android.R.id.text1);
				int resId = mContext.getResources().getIdentifier(
						items[position].icon, "drawable",
						mContext.getPackageName());
				tv.setCompoundDrawablesWithIntrinsicBounds(resId, 0, 0, 0);
				tv.setTextSize((float) 20);
				int dp5 = (int) (8 * getResources().getDisplayMetrics().density + 0.5f);
				tv.setCompoundDrawablePadding(dp5);
				return v;
			}
		};

		mActionDialog = new AlertDialog.Builder(mContext).setTitle(
				getString(R.string.txt_share_dialog)).setAdapter(adapter,
				new DialogInterface.OnClickListener() {
					public void onClick(DialogInterface dialog, int which) {
						if (TextUtils.isEmpty(mVideoUrl)) {
							mContext.showToast(getString(R.string.toast_create_first));
							return;
						}
						String tripName = (String) TravelPrefs.getData(
								mContext, TravelPrefs.PREF_TRIP_NAME);
						switch (which) {
						case 0:
							NMShareMessage message = new NMShareMessage();
							message.setMessage(" ");
							message.setType(NMShareType.NMShareTypeStory);
							message.setPicture(mUrlThumbnail);
							message.setName(getString(
									R.string.subject_slideshow, tripName));
							message.setCaption("Created with the Travel Buddy app");
							message.setDescription(getString(
									R.string.description_slideshow_fb, tripName));
							message.setLink(mVideoUrl);
							NMShareKit shareKit = NMShareKit
									.sharedInstance(mContext);
							shareKit.shareFB(message);
							break;
						case 1:
							Intent emailIntent = new Intent(
									android.content.Intent.ACTION_SEND);
							emailIntent.setType("text/html");
							emailIntent.putExtra(
									android.content.Intent.EXTRA_SUBJECT,
									getString(R.string.subject_slideshow,
											tripName));
							emailIntent.putExtra(
									android.content.Intent.EXTRA_TEXT,
									getString(R.string.content_slideshow_link,
											tripName, mVideoUrl));
							startActivity(Intent.createChooser(emailIntent,
									"Send your slideshow..."));
							break;
						default:
							break;
						}
					}
				});
	}
}
