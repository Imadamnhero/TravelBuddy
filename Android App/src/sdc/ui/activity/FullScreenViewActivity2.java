package sdc.ui.activity;

import java.io.File;

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
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Bitmap.Config;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.view.View;
import android.widget.TextView;

import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.process.BitmapProcessor;

public class FullScreenViewActivity2 extends Activity {
	private DisplayImageOptions optionsNetwork = new DisplayImageOptions.Builder()
			.cacheOnDisc(true)
			.showImageOnLoading(R.drawable.bg_img_default)
			.cacheInMemory(false)
			.considerExifParams(true)
			.showImageForEmptyUri(R.drawable.bg_img_default)
			.postProcessor(new BitmapProcessor() {

				@Override
				public Bitmap process(Bitmap bmp) {
					return Bitmap.createScaledBitmap(bmp, screenWidth,
							bmp.getHeight() * screenWidth / bmp.getWidth(),
							false);
				}
			}).resetViewBeforeLoading(true)
			.showImageOnFail(R.drawable.bg_img_default).build();
	private DisplayImageOptions optionsLocal = new DisplayImageOptions.Builder()
			.considerExifParams(true)
			.showImageOnLoading(R.drawable.bg_img_default).cacheInMemory(false)
			.bitmapConfig(Config.RGB_565).postProcessor(new BitmapProcessor() {

				@Override
				public Bitmap process(Bitmap bmp) {
					return Bitmap.createScaledBitmap(bmp, screenWidth,
							bmp.getHeight() * screenWidth / bmp.getWidth(),
							false);
				}
			}).showImageOnFail(R.drawable.bg_img_default).build();

	private TextView tv_description;
	private TouchImageView touchImage;
	private View btnClose, btnDelete;
	private int screenWidth;

	@SuppressWarnings("deprecation")
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.layout_fullscreen_receipt);
		screenWidth = getWindowManager().getDefaultDisplay().getWidth();

		tv_description = (TextView) findViewById(R.id.tv_description);
		touchImage = (TouchImageView) findViewById(R.id.imgDisplay);
		btnClose = findViewById(R.id.btnClose);
		btnDelete = findViewById(R.id.btnDelete);
		btnClose.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				FullScreenViewActivity2.this.finish();
			}
		});
		btnDelete.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				showDeleteDialog();
			}
		});
		Intent i = getIntent();
		boolean isLocal = i.getBooleanExtra("isLocal", false);
		String imageUrl = i.getStringExtra("image");
		if (isLocal) {
			// File imgFile = new File(imageUrl);
			// if (imgFile.exists()) {
			// Bitmap myBitmap = BitmapFactory.decodeFile(imgFile
			// .getAbsolutePath());
			// touchImage.setImageBitmap(myBitmap);
			// }
			ImageLoader.getInstance().displayImage("file://" + imageUrl,
					touchImage, optionsLocal);
		} else {
			ImageLoader.getInstance().displayImage(BaseWS.HOST + imageUrl,
					touchImage, optionsNetwork);
		}
		tv_description.setText(i.getStringExtra("date"));
	}

	protected void showDeleteDialog() {
		CustomDialog dialog = new CustomDialog(this,
				this.getString(R.string.choose_picture_title),
				this.getString(R.string.txt_confirm_delete_photo));
		dialog.getWindow().setBackgroundDrawable(
				new ColorDrawable(android.graphics.Color.TRANSPARENT));
		dialog.setOnClickLeft(new CustomDialog.OnClickLeft() {

			@Override
			public void click() {
				Intent intent = getIntent();
				int clientId = intent.getIntExtra("clientId", -1);
				int serverId = intent.getIntExtra("serverId", 0);
				new PhotoTableAdapter(FullScreenViewActivity2.this)
						.deleteOfflineUponId(clientId);
				Photo photo = new Photo(clientId, (Integer) TravelPrefs
						.getData(FullScreenViewActivity2.this,
								TravelPrefs.PREF_USER_ID), serverId,
						ContentProviderDB.FLAG_DEL);
				SyncPhotosWS.fetchData(FullScreenViewActivity2.this,
						(Integer) TravelPrefs.getData(
								FullScreenViewActivity2.this,
								TravelPrefs.PREF_USER_ID), photo, null);

				FullScreenViewActivity2.this.finish();
			}
		});
		dialog.setOnClickRight(new CustomDialog.OnClickRight() {

			@Override
			public void click() {

			}
		});
		dialog.show();
		dialog.setTextBtn(this.getString(R.string.btn_yes),
				this.getString(R.string.btn_no));
	}
}
