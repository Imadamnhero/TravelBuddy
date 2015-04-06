package sdc.ui.fragment;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;

import sdc.application.TravelApplication;
import sdc.application.TravelPrefs;
import sdc.data.Photo;
import sdc.data.database.ContentProviderDB;
import sdc.data.database.adapter.PhotoTableAdapter;
import sdc.net.webservice.SyncPhotosWS;
import sdc.travelapp.R;
import sdc.ui.customview.CustomDialog;
import sdc.ui.travelapp.MainActivity;
import sdc.ui.utils.StringUtils;
import sdc.ui.utils.Utils;
import android.app.Activity;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Bitmap.CompressFormat;
import android.graphics.Bitmap.Config;
import android.graphics.drawable.ColorDrawable;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Bundle;
import android.provider.MediaStore;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.Toast;

import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.assist.ImageScaleType;

public class TakePhotoFragment extends BaseTripFragment implements
		View.OnClickListener {
	public static final String TITLE = "Take photo";
	private ImageView photoview;
	private String myImagePath;
	private View btnDelete, btn_save;
	private Button btnAdd;
	private EditText ed_description;
	private static final int CAPTURE_IMAGE = 100;
	private MainActivity mContext;

	public TakePhotoFragment() {
		super(TITLE);
	}

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		View root = inflater.inflate(R.layout.fragment_takephoto, container,
				false);
		mContext = (MainActivity) getActivity();
		photoview = (ImageView) root.findViewById(R.id.im_photoview);
		btnAdd = (Button) root.findViewById(R.id.btn_add);
		btnDelete = root.findViewById(R.id.btn_delete_photo);
		btn_save = root.findViewById(R.id.btn_save);
		ed_description = (EditText) root.findViewById(R.id.ed_description);
		return root;
	}

	@Override
	public void onDestroyView() {
		super.onDestroyView();
		if (myImagePath != null)
			new File(myImagePath).delete();
	}

	@Override
	protected void addListener() {
		btnAdd.setOnClickListener(this);
		btnDelete.setOnClickListener(this);
		btn_save.setOnClickListener(this);
		super.addListener();
	}

	@Override
	protected void initComponents() {
		try {
			onClickTakeAPhoto();
		} catch (Exception e) {
			Toast.makeText(getActivity(), getString(R.string.err_open_camera),
					Toast.LENGTH_LONG).show();
		}

	}

	@Override
	public void preLoadData() {
		// TODO Auto-generated method stub

	}

	@Override
	public void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);
		if (resultCode == Activity.RESULT_OK) {
			switch (requestCode) {
			case CAPTURE_IMAGE:
				// myDialog.dismiss();
				ImageLoader.getInstance().displayImage(
						"file://" + myImagePath,
						photoview,
						new DisplayImageOptions.Builder()
								.bitmapConfig(Config.RGB_565)
								.imageScaleType(
										ImageScaleType.IN_SAMPLE_POWER_OF_2)
								.build());
				break;
			}

		}
	}

	public void onClickTakeAPhoto() {
		File file = new File(getActivity().getExternalFilesDir("photos"),
				"photo_" + System.currentTimeMillis() + ".jpg");
		myImagePath = file.getAbsolutePath();

		Intent takePictureIntent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
		takePictureIntent.putExtra(android.provider.MediaStore.EXTRA_OUTPUT,
				Uri.fromFile(file));
		takePictureIntent.putExtra("return-data", true);
		takePictureIntent.putExtra(MediaStore.EXTRA_FINISH_ON_COMPLETION, true);
		startActivityForResult(takePictureIntent, CAPTURE_IMAGE);

		// File file = new File(getActivity().getExternalFilesDir("photos"),
		// "photo_" + System.currentTimeMillis() + ".jpg");
		// myImagePath = file.getAbsolutePath();
	}

	@Override
	public void onClick(View v) {
		if (v == btnAdd) {
			try {
				onClickTakeAPhoto();
			} catch (Exception e) {

			}
		}
		if (v == btnDelete) {
			showDeleteDialog();
		}
		if (v == btn_save) {
			String description = ed_description.getText().toString();
			if (myImagePath != null && new File(myImagePath).exists()
					&& description.length() < 40 && description.length() > 0
					&& !StringUtils.isOnlyContainSpace(description)) {
				saveFile(myImagePath);
			} else {
				if (myImagePath == null || (!new File(myImagePath).exists()))
					Toast.makeText(getActivity(),
							getString(R.string.txt_add_photo),
							Toast.LENGTH_LONG).show();
				else
					Toast.makeText(getActivity(),
							getString(R.string.txt_write_description),
							Toast.LENGTH_LONG).show();
			}
		}

	}

	private void saveFile(String source) {
		new AsyncTask<String, Void, String>() {
			private ProgressDialog mDialog;
			private String path;

			protected void onPreExecute() {
				File file = new File(getActivity()
						.getExternalFilesDir("photos"), "photo_"
						+ System.currentTimeMillis() + ".jpg");
				path = file.getAbsolutePath();
				mDialog = new ProgressDialog(mContext);
				mDialog.setMessage("Saving...");
				mDialog.setOnCancelListener(new DialogInterface.OnCancelListener() {

					@Override
					public void onCancel(DialogInterface dialog) {
						cancel(true);
						File file = new File(path);
						if (file.exists()) {
							file.delete();
						}
					}
				});
				mDialog.show();
			};

			protected String doInBackground(String... params) {
				try {
					System.gc();
					Bitmap bitmap = Utils.createSlideShowPhoto(mContext,
							params[0], ed_description.getText().toString());
					bitmap.compress(CompressFormat.JPEG, 100,
							new FileOutputStream(new File(path)));
					bitmap.recycle();
					bitmap = null;
					return path;
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				} catch (OutOfMemoryError e) {
					e.printStackTrace();
				}
				return null;
			};

			protected void onPostExecute(String result) {
				if (mDialog.isShowing()) {
					mDialog.dismiss();
				}
				if (result != null) {
					Toast.makeText(getActivity(),
							getString(R.string.toast_save_photo_slideshow),
							Toast.LENGTH_LONG).show();
					// add to local database first
					Photo newPhoto = new Photo(-1, result, ed_description
							.getText().toString(), mContext.getUserId(),
							mContext.getTripId(), false, 0,
							ContentProviderDB.FLAG_ADD);
					int newId = new PhotoTableAdapter(mContext).addPhoto(
							newPhoto, newPhoto.getTripId(), 0,
							newPhoto.getFlag());
					// upload to server
					newPhoto.setId(newId);
					if (TravelApplication.isOnline(mContext))
						SyncPhotosWS.doUpload(mContext.getApplicationContext(),
								(Integer) TravelPrefs.getData(mContext,
										TravelPrefs.PREF_USER_ID), mContext
										.getTripId());

					photoview.setImageBitmap(null);
					ed_description.setText("");
					btnAdd.setVisibility(View.VISIBLE);
					btnDelete.setVisibility(View.GONE);
					File file = new File(myImagePath);
					if (file.exists()) {
						file.delete();
					}
					myImagePath = null;
					path = null;
				} else {
					File file = new File(path);
					if (file.exists()) {
						file.delete();
					}
				}
			};

		}.execute(source);
	}

	protected void showDeleteDialog() {
		CustomDialog dialog = new CustomDialog(getActivity(),
				getString(R.string.delete_photo),
				getString(R.string.content_delete_photo));
		dialog.getWindow().setBackgroundDrawable(
				new ColorDrawable(android.graphics.Color.TRANSPARENT));
		dialog.setOnClickLeft(new CustomDialog.OnClickLeft() {

			@Override
			public void click() {
				photoview.setImageBitmap(null);
				btnAdd.setVisibility(View.VISIBLE);
				btnDelete.setVisibility(View.GONE);
				if (myImagePath != null)
					new File(myImagePath).delete();
			}
		});
		dialog.setOnClickRight(new CustomDialog.OnClickRight() {

			@Override
			public void click() {
			}
		});
		dialog.show();
		dialog.setTextBtn(getString(R.string.btn_yes),
				getString(R.string.btn_no));
	}

}
