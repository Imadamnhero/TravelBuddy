package sdc.ui.fragment;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.util.List;

import sdc.application.TravelPrefs;
import sdc.net.webservice.EditAccountWS;
import sdc.travelapp.R;
import sdc.ui.customview.CustomSingleChoiceDialog;
import sdc.ui.travelapp.MainActivity;
import sdc.ui.utils.StringUtils;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ResolveInfo;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.Bitmap.Config;
import android.graphics.drawable.ColorDrawable;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.provider.MediaStore;
import android.provider.MediaStore.Images;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.Toast;

import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.assist.ImageScaleType;

public class AccountFragment extends BaseTripFragment implements
		View.OnClickListener {
	public static final String TITLE = "Account	";
	private Uri mImageCaptureUri;
	private String myImagePath;
	private static final int CAPTURE_IMAGE = 100;
	private static final int SELECT_PICTURE = 101;
	private static final int CROP_PHOTO_CODE = 102;
	private int myCropID;
	private ImageView imAvatar;
	private Bitmap selectedAvatar;
	private Bitmap bitmap;
	private String myImagePathCrop = "";
	private EditText mEdtName, mEdtMail, mEdtCurPass, mEdtNewPass, mEdtConfirm;
	private ImageView btnDel;

	public AccountFragment() {
		super(TITLE);
	}

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		View root = inflater.inflate(R.layout.fragment_account, container,
				false);
		return root;
	}

	@Override
	public void onDestroyView() {
		super.onDestroyView();
		if (!TextUtils.isEmpty(myImagePathCrop)) {
			File file = new File(myImagePathCrop);
			file.delete();
		}
	}

	@Override
	protected void addListener() {
		imAvatar = (ImageView) getView().findViewById(R.id.im_avatar);
		imAvatar.setOnClickListener(this);
		getView().findViewById(R.id.btn_save).setOnClickListener(this);
		btnDel.setOnClickListener(this);
		super.addListener();
	}

	@Override
	protected void initComponents() {
		mEdtName = (EditText) getView().findViewById(R.id.et1);
		mEdtMail = (EditText) getView().findViewById(R.id.et2);
		mEdtCurPass = (EditText) getView().findViewById(R.id.et3);
		mEdtNewPass = (EditText) getView().findViewById(R.id.et4);
		mEdtConfirm = (EditText) getView().findViewById(R.id.et5);
		btnDel = (ImageView) getView().findViewById(R.id.btn_delete_photo);
		mEdtMail.setEnabled(false);
	}

	@Override
	public void preLoadData() {
		mEdtCurPass.setText("");
		mEdtNewPass.setText("");
		mEdtConfirm.setText("");
		mEdtName.setText((String) TravelPrefs.getData(getActivity(),
				TravelPrefs.PREF_USER_NAME));
		mEdtMail.setText((String) TravelPrefs.getData(getActivity(),
				TravelPrefs.PREF_USER_MAIL));
		ImageLoader.getInstance().displayImage(
				(String) TravelPrefs.getData(getActivity(),
						TravelPrefs.PREF_USER_AVATAR), imAvatar);
	}

	@Override
	public void onClick(View v) {
		if (v == imAvatar) {
			showDialogPhoto(getString(R.string.choose_picture_title));
		}
		if (v.getId() == R.id.btn_save) {
			MainActivity context = (MainActivity) getActivity();
			String passInput = mEdtCurPass.getText() + "";
			String correctPass = (String) TravelPrefs.getData(getActivity(),
					TravelPrefs.PREF_USER_PASS);
			String newpass = mEdtNewPass.getText() + "";
			String confirmpass = mEdtConfirm.getText() + "";
			String username = mEdtName.getText() + "";
			if (validateInput(passInput, correctPass, newpass, confirmpass,
					username, myImagePathCrop)) {
				new EditAccountWS().fetchData(context, passInput, newpass,
						username, String.valueOf((Integer) TravelPrefs.getData(
								getActivity(), TravelPrefs.PREF_USER_ID)),
						myImagePathCrop);
			}
		}
		if (v.getId() == R.id.btn_delete_photo) {
			bitmap = null;
			imAvatar.setImageBitmap(bitmap);
			ImageLoader.getInstance().displayImage(
					(String) TravelPrefs.getData(getActivity(),
							TravelPrefs.PREF_USER_AVATAR), imAvatar);
			btnDel.setVisibility(View.GONE);
			File file = new File(myImagePathCrop);
			file.delete();
		}
	}

	private boolean validateInput(String pass, String correctPass,
			String newpass, String confirmpass, String name, String imagePath) {
		MainActivity activity = ((MainActivity) getActivity());
		if (TextUtils.isEmpty(name)) {
			activity.showToast(getString(R.string.toast_blank_name) + "\n");
		} else if (StringUtils.isOnlyContainSpace(name)) {
			activity.showToast(getString(R.string.toast_invalid_name) + "\n");
		} else if (TextUtils.isEmpty(pass) && TextUtils.isEmpty(newpass)
				&& TextUtils.isEmpty(confirmpass)) {
			// 3 pass all is blank will be valid too
			return true;
		} else if (TextUtils.isEmpty(pass)) {
			activity.showToast(getString(R.string.toast_blank_current_pass)
					+ "\n");
			// } else if (!StringUtils.isPassValid(pass)) {
			// activity.showToast(getString(R.string.toast_wrong_pass) + "\n");
		} else if (!TextUtils.isEmpty(pass) && (TextUtils.isEmpty(newpass))) {
			activity.showToast(getString(R.string.toast_blank_newpass) + "\n");
		} else if (!TextUtils.isEmpty(pass) && (TextUtils.isEmpty(confirmpass))) {
			activity.showToast(getString(R.string.toast_blank_confirmpass)
					+ "\n");
			// } else if (!StringUtils.isPassValid(newpass)
			// && !StringUtils.isPassValid(confirmpass)) {
			// activity.showToast(getString(R.string.toast_invalid_pass) +
			// "\n");
		} else if (!newpass.equals(confirmpass)) {
			activity.showToast(getString(R.string.toast_wrong_confirm_pass)
					+ "\n");
		} else if (!correctPass.equals(pass)) {
			activity.showToast(getString(R.string.toast_wrong_pass) + "\n");
		} else {
			return true;
		}
		return false;

	}

	public void showDialogPhoto(String title) {
		final CustomSingleChoiceDialog dialog = new CustomSingleChoiceDialog(
				getActivity(), title, getString(R.string.choose_picture_item1),
				getString(R.string.choose_picture_item2));
		dialog.getWindow().setBackgroundDrawable(
				new ColorDrawable(android.graphics.Color.TRANSPARENT));
		dialog.setOnClickTop(new CustomSingleChoiceDialog.OnClickLeft() {

			@Override
			public void Click() {
				dialog.dismiss();
				onClickTakeAPhoto();
			}
		});
		dialog.setOnClickBottom(new CustomSingleChoiceDialog.OnClickRight() {

			@Override
			public void Click() {
				dialog.dismiss();
				onClickChooseFromGallery();
			}
		});
		try {
			dialog.show();
		} catch (Exception e) {

		}
		dialog.setTextBtn(getString(R.string.btn_cancel));
	}

	public void onClickTakeAPhoto() {
		Intent takePictureIntent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
		File file = new File(Environment.getExternalStorageDirectory(),
				String.valueOf(System.currentTimeMillis()) + ".jpg");
		mImageCaptureUri = Uri.fromFile(file);
		myImagePath = file.getPath();
		takePictureIntent.putExtra(android.provider.MediaStore.EXTRA_OUTPUT,
				mImageCaptureUri);
		takePictureIntent.putExtra("return-data", true);
		takePictureIntent.putExtra(MediaStore.EXTRA_FINISH_ON_COMPLETION, true);
		startActivityForResult(takePictureIntent, CAPTURE_IMAGE);
	}

	public void onClickChooseFromGallery() {
		Intent intent_gallery = new Intent(Intent.ACTION_PICK,
				android.provider.MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
		startActivityForResult(intent_gallery, SELECT_PICTURE);

	}

	@Override
	public void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);
		if (resultCode == Activity.RESULT_OK) {
			switch (requestCode) {
			case CAPTURE_IMAGE:
				// myDialog.dismiss();
				try {
					doCrop();
				} catch (Exception e) {
					// TODO: handle exception
				}
				break;
			case SELECT_PICTURE:
				// myDialog.dismiss();
				mImageCaptureUri = data.getData();
				File finalFile1 = new File(getRealPathFromURI(mImageCaptureUri));
				myImagePath = finalFile1.getPath();
				try {
					doCrop();
				} catch (Exception e) {
				}
				break;
			case CROP_PHOTO_CODE:
				ImageLoader.getInstance().displayImage(
						"file://" + myImagePathCrop,
						imAvatar,
						new DisplayImageOptions.Builder()
								.imageScaleType(
										ImageScaleType.IN_SAMPLE_POWER_OF_2)
								.bitmapConfig(Config.RGB_565).build());
				break;
			}

		}
	}

	public Uri getImageUri(Context inContext, Bitmap inImage) {
		/*
		 * Intent intent_gallery = new Intent( Intent.ACTION_PICK,
		 * android.provider.MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
		 * startActivityForResult(intent_gallery, typeNoCam);
		 */
		ByteArrayOutputStream bytes = new ByteArrayOutputStream();
		inImage.compress(Bitmap.CompressFormat.JPEG, 100, bytes);
		String path = Images.Media.insertImage(inContext.getContentResolver(),
				inImage, "Title", null);
		return Uri.parse(path);
	}

	private void doCrop() {
		Intent intent = new Intent("com.android.camera.action.CROP");
		intent.setType("image/*");

		List<ResolveInfo> list = getActivity().getPackageManager()
				.queryIntentActivities(intent, 0);

		int size = list.size();

		if (size == 0) {
			Toast.makeText(getActivity(),
					getResources().getString(R.string.txt_cannot_find),
					Toast.LENGTH_SHORT).show();
			return;
		} else {
			intent.setDataAndType(mImageCaptureUri, "image/*");

			// set crop properties
			intent.putExtra("aspectX", 1);
			intent.putExtra("aspectY", 1);
			intent.putExtra("return-false", false);

			File file = new File(getActivity().getExternalFilesDir("photos"),
					"photo_" + System.currentTimeMillis() + ".jpg");
			myImagePathCrop = file.getAbsolutePath();

			intent.putExtra(MediaStore.EXTRA_OUTPUT, Uri.fromFile(file));

			try {
				startActivityForResult(intent, CROP_PHOTO_CODE);
			} catch (Exception e) {

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

	public String getRealPathCropFromURI(Uri uri) {
		Cursor cursor = getActivity().getContentResolver().query(uri, null,
				null, null, null);
		cursor.moveToFirst();
		int idx = cursor.getColumnIndex(MediaStore.Images.ImageColumns.DATA);
		myCropID = cursor.getInt(cursor
				.getColumnIndex(MediaStore.Images.ImageColumns._ID));
		return cursor.getString(idx);
	}

}
