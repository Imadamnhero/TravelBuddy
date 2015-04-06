package sdc.ui.activity;

import java.io.File;

import sdc.application.TravelPrefs;
import sdc.data.database.adapter.SlideShowTableAdapter;
import sdc.net.webservice.task.DownloadFileFromURLTask;
import sdc.travelapp.R;
import android.app.Activity;
import android.media.MediaPlayer;
import android.media.MediaPlayer.OnPreparedListener;
import android.net.Uri;
import android.os.Bundle;
import android.view.Gravity;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.MediaController;
import android.widget.Toast;
import android.widget.VideoView;

import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;

public class SlideShowActivity extends Activity {
	private String mVideoLink;
	private String mThumbnail;
	private String mFilePath = null;
	private VideoView mVideoView;
	private View mLayoutThumb;
	private FrameLayout mLayoutVideo;
	private FrameLayout mLayoutController;
	private MediaController mController;
	private View mProgressBar;
	private boolean isShowMediaController = false;
	private FrameLayout.LayoutParams mControllerLayoutParams;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_view_slideshow);
		mVideoLink = getIntent().getStringExtra("video");
		mThumbnail = getIntent().getStringExtra("thumbnail");

		DisplayImageOptions optionsNetwork = new DisplayImageOptions.Builder()
				.cacheOnDisc(true).showImageOnLoading(R.drawable.home_bg)
				.considerExifParams(true).resetViewBeforeLoading(true)
				.showImageOnFail(R.drawable.home_bg).build();
		ImageView thumbImageView = (ImageView) findViewById(R.id.img_thumb);
		ImageLoader.getInstance().displayImage(mThumbnail, thumbImageView,
				optionsNetwork);

		mLayoutThumb = findViewById(R.id.frame_thumbnail);
		mLayoutVideo = (FrameLayout) findViewById(R.id.frame_video);
		mLayoutController = (FrameLayout) findViewById(R.id.frame_controller);
		mVideoView = (VideoView) findViewById(R.id.video_view);
		mProgressBar = findViewById(R.id.prg_loading);

		mController = new MediaController(this);// (MediaController)
												// findViewById(R.id.media_controller);

		mController.setMediaPlayer(mVideoView);
		mController.setAnchorView(mVideoView);

		mControllerLayoutParams = new FrameLayout.LayoutParams(
				FrameLayout.LayoutParams.MATCH_PARENT,
				FrameLayout.LayoutParams.WRAP_CONTENT);
		mControllerLayoutParams.gravity = Gravity.BOTTOM;

		((ViewGroup) mController.getParent()).removeView(mController);

		mLayoutController.addView(mController, mControllerLayoutParams);
		// mVideoView.setMediaController(mController);
		mController.setPrevNextListeners(new View.OnClickListener() {
			@Override
			public void onClick(View v) {

			}
		}, new View.OnClickListener() {
			@Override
			public void onClick(View v) {

			}
		});

		mVideoView
				.setOnCompletionListener(new MediaPlayer.OnCompletionListener() {

					@Override
					public void onCompletion(MediaPlayer mp) {
						mController.hide();
						mLayoutThumb.setVisibility(View.VISIBLE);
						mLayoutVideo.setVisibility(View.INVISIBLE);
						isShowMediaController = false;
					}
				});
		mVideoView.setOnTouchListener(new View.OnTouchListener() {

			@Override
			public boolean onTouch(View v, MotionEvent event) {
				if (event.getAction() == MotionEvent.ACTION_DOWN) {
					if (mLayoutController.getVisibility() == View.VISIBLE) {
						mController.hide();
						mLayoutController.setVisibility(View.INVISIBLE);
					} else {
						mController.show(0);
						mLayoutController.setVisibility(View.VISIBLE);
					}
				}
				return false;
			}
		});
		onPlayVideo(null);

	}

	public void onBack(View v) {
		finish();
	}

	@Override
	public void finish() {
		super.finish();
		overridePendingTransition(R.anim.slide_in_left, R.anim.slide_out_right);
	}

	public void onPlayVideo(View v) {
		mLayoutThumb.setVisibility(View.INVISIBLE);
		mLayoutVideo.setVisibility(View.VISIBLE);
		// Intent intent = new Intent(Intent.ACTION_VIEW);
		// if (mFilePath == null) {
		// intent.setDataAndType(Uri.parse(mVideoLink), "video/*");
		// } else {
		// intent.setDataAndType(Uri.fromFile(new File(mFilePath)), "video/*");
		// }
		// startActivity(Intent.createChooser(intent, "View SlideShow"));
		Uri uri;
		if (mFilePath == null) {
			uri = Uri.parse(mVideoLink);
		} else {
			uri = Uri.fromFile(new File(mFilePath));
		}
		mVideoView.setVideoURI(uri);
		mVideoView.requestFocus();
		mProgressBar.setVisibility(View.VISIBLE);
		mVideoView.setOnPreparedListener(new OnPreparedListener() {

			@Override
			public void onPrepared(MediaPlayer mp) {
				mLayoutController.setVisibility(View.VISIBLE);
				mProgressBar.setVisibility(View.GONE);
				mVideoView.start();
				mController.show(0);
				isShowMediaController = true;
			}
		});

	}

	public void onDownload(View v) {
		if (mFilePath != null) {
			Toast.makeText(this, "SlideShow is already downloaded",
					Toast.LENGTH_LONG).show();
		} else {
			new DownloadFileFromURLTask(this) {
				public void onSuccess(String filePath) {
					mFilePath = filePath;
					new SlideShowTableAdapter(SlideShowActivity.this).add(
							mFilePath, mVideoLink, mThumbnail,
							(Integer) TravelPrefs.getData(
									SlideShowActivity.this,
									TravelPrefs.PREF_TRIP_ID),
							(Integer) TravelPrefs.getData(
									SlideShowActivity.this,
									TravelPrefs.PREF_USER_ID));
				};
			}.execute(mVideoLink);
		}
	}
}
