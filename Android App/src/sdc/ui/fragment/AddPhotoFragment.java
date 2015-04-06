package sdc.ui.fragment;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Date;

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
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.Bitmap.CompressFormat;
import android.graphics.Bitmap.Config;
import android.graphics.drawable.ColorDrawable;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Bundle;
import android.provider.MediaStore;
import android.provider.MediaStore.Images;
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

public class AddPhotoFragment extends BaseTripFragment implements
		View.OnClickListener {
	public static final String TITLE = "Add Photo";
	private ImageView photoview;
	private String myImagePath;
	private String mySelectedFile;
	private View btnDelete, btn_save;
	private Button btnAdd;
	private EditText ed_description;
	private static final int SELECT_PICTURE = 101;
	private MainActivity mContext;

	public AddPhotoFragment() {
		super(TITLE);
	}

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		View root = inflater.inflate(R.layout.fragment_addphoto, container,
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
			onClickChooseFromGallery();
		} catch (Exception e) {
			Toast.makeText(getActivity(), getString(R.string.err_open_gallery),
					Toast.LENGTH_LONG).show();
		}

	}

	@Override
	public void preLoadData() {
		// TODO Auto-generated method stub

	}

	@Override
	public void onClick(View v) {
		if (v == btnAdd) {
			try {
				onClickChooseFromGallery();
			} catch (Exception e) {
			}
		}
		if (v == btnDelete) {
			showDeleteDialog();
		}
		if (v == btn_save) {
			String description = ed_description.getText().toString();
			if (mySelectedFile != null && new File(mySelectedFile).exists()
					&& description.length() < 40 && description.length() > 0
					&& !StringUtils.isOnlyContainSpace(description)) {
				saveFile(mySelectedFile);
			} else {
				if (mySelectedFile == null
						|| (!new File(mySelectedFile).exists()))
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

	public void onClickChooseFromGallery() {
		// Intent intent_gallery = new Intent(Intent.ACTION_PICK,
		// android.provider.MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
		// startActivityForResult(intent_gallery, SELECT_PICTURE);

		Intent pickImageIntent = new Intent(Intent.ACTION_PICK);

		pickImageIntent.setType("image/*");
		// pickImageIntent.putExtra("crop", "true");
		// pickImageIntent.putExtra("aspectX", 1);
		// pickImageIntent.putExtra("aspectY", 1);
		// pickImageIntent.putExtra("outputX", 800);
		// pickImageIntent.putExtra("outputY", 800);
		// pickImageIntent.putExtra("scale", true);
		// pickImageIntent.putExtra("scaleIfNeeded", true);
		// pickImageIntent.putExtra(MediaStore.EXTRA_OUTPUT,
		// Uri.fromFile(file));
		// pickImageIntent.putExtra("outputFormat",
		// Bitmap.CompressFormat.JPEG.toString());

		startActivityForResult(pickImageIntent, SELECT_PICTURE);

	}

	@Override
	public void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);
		if (resultCode == Activity.RESULT_OK) {
			switch (requestCode) {
			case SELECT_PICTURE:
				mySelectedFile = getRealPathFromURI(data.getData());
				ImageLoader.getInstance().displayImage(
						"file://" + mySelectedFile,
						photoview,
						new DisplayImageOptions.Builder()
								.bitmapConfig(Config.RGB_565)
								.considerExifParams(true)
								.imageScaleType(
										ImageScaleType.IN_SAMPLE_POWER_OF_2)
								.build());
				break;
			}

		}
	}

	public String getRealPathFromURI(Uri uri) {
		Cursor cursor = getActivity().getContentResolver().query(uri, null,
				null, null, null);
		cursor.moveToFirst();
		int idx = cursor.getColumnIndex(MediaStore.Images.ImageColumns.DATA);
		return cursor.getString(idx);
	}

	public Uri getImageUri(Context inContext, Bitmap inImage) {
		ByteArrayOutputStream bytes = new ByteArrayOutputStream();
		inImage.compress(Bitmap.CompressFormat.JPEG, 100, bytes);
		String path = Images.Media.insertImage(inContext.getContentResolver(),
				inImage, String.valueOf(new Date().getTime()), null);
		return Uri.parse(path);
	}

	private void saveFile(String source) {
		new AsyncTask<String, Void, String>() {
			private ProgressDialog mDialog;

			protected void onPreExecute() {
				File file = new File(getActivity()
						.getExternalFilesDir("photos"), "photo_"
						+ System.currentTimeMillis() + ".jpg");
				myImagePath = file.getAbsolutePath();
				mDialog = new ProgressDialog(mContext);
				mDialog.setMessage("Saving...");
				mDialog.setOnCancelListener(new DialogInterface.OnCancelListener() {

					@Override
					public void onCancel(DialogInterface dialog) {
						cancel(true);
						File file = new File(myImagePath);
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
							new FileOutputStream(new File(myImagePath)));
					bitmap.recycle();
					bitmap = null;
					return myImagePath;
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
					Photo newPhoto = new Photo(-1, myImagePath, ed_description
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
					myImagePath = null;
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
				myImagePath = null;
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