package sdc.ui.fragment;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.util.List;

import sdc.net.webservice.CreateAccountWS;
import sdc.travelapp.R;
import sdc.ui.customview.CustomSingleChoiceDialog;
import sdc.ui.travelapp.MainActivity;
import sdc.ui.travelapp.MainActivity.Screen;
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

public class CreateAccFragment extends BaseHomeFragment implements
		View.OnClickListener {
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
	private ImageView btnDel;
	private EditText mEdtName, mEdtMail, mEdtPass;

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		View root = inflater.inflate(R.layout.fragment_create_acc, container,
				false);
		return root;
	}

	@Override
	protected void addListener() {
		super.addListener();
		getView().findViewById(R.id.btn_create).setOnClickListener(this);
		getView().findViewById(R.id.tv_link).setOnClickListener(this);
		imAvatar = (ImageView) getView().findViewById(R.id.im_avatar);
		imAvatar.setOnClickListener(this);
		btnDel.setOnClickListener(this);
	}

	@Override
	protected void initComponents() {
		getView().findViewById(R.id.title_btn_menu).setVisibility(View.GONE);
		btnDel = (ImageView) getView().findViewById(R.id.btn_delete_photo);
		mEdtName = (EditText) getView().findViewById(R.id.et_name);
		mEdtMail = (EditText) getView().findViewById(R.id.et_mail);
		mEdtPass = (EditText) getView().findViewById(R.id.et_pass);
	}

	@Override
	public void preLoadData() {
		// TODO Auto-generated method stub

	}

	@Override
	public void onClick(View v) {
		MainActivity activity = ((MainActivity) getActivity());
		if (v.getId() == R.id.btn_create) {
			String name = mEdtName.getText() + "";
			String mail = mEdtMail.getText() + "";
			String pass = mEdtPass.getText() + "";
			if (validateInput(name, mail, pass, myImagePathCrop)) {
				new CreateAccountWS().fetchData(activity, name, mail, pass,
						myImagePathCrop);
			}
		} else if (v.getId() == R.id.tv_link) {
			activity.changeScreen(Screen.LOGIN);
		} else if (v.getId() == R.id.im_avatar) {
			try {
				showDialogPhoto(getString(R.string.choose_picture_title));
			} catch (Exception e) {
			}
		}
		if (v.getId() == R.id.btn_delete_photo) {
			bitmap = null;
			imAvatar.setImageBitmap(bitmap);
			imAvatar.setImageResource(R.drawable.default_avatar);
			myImagePathCrop = null;
			btnDel.setVisibility(View.GONE);
		}
	}

	private boolean validateInput(String name, String mail, String pass,
			String imagePath) {
		MainActivity activity = ((MainActivity) getActivity());
		String toastMessage = "";
		if (TextUtils.isEmpty(name)) {
			toastMessage += getString(R.string.toast_blank_name) + "\n";
		} else if (StringUtils.isOnlyContainSpace(name)) {
			toastMessage += getString(R.string.toast_invalid_name) + "\n";
		}
		if (TextUtils.isEmpty(mail)) {
			toastMessage += getString(R.string.toast_blank_mail) + "\n";
		} else if (!StringUtils.isEmailValid(mail)) {
			toastMessage += getString(R.string.toast_invalid_mail) + "\n";
		}
		if (TextUtils.isEmpty(pass)) {
			toastMessage += getString(R.string.toast_blank_pass) + "\n";
		}// else if (!StringUtils.isPassValid(pass)) {
			// toastMessage += getString(R.string.toast_invalid_pass) + "\n";
			// }
		if (TextUtils.isEmpty(imagePath)) {
			toastMessage += getString(R.string.toast_blank_avatar) + "\n";
		}
		if (toastMessage.length() > 0) {
			activity.showToast(toastMessage.substring(0,
					toastMessage.length() - 1));
			return false;
		} else
			return true;
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
				try {
					onClickTakeAPhoto();
				} catch (Exception e) {
					Toast.makeText(getActivity(),
							getString(R.string.err_open_camera),
							Toast.LENGTH_LONG).show();
				}
			}
		});
		dialog.setOnClickBottom(new CustomSingleChoiceDialog.OnClickRight() {

			@Override
			public void Click() {
				dialog.dismiss();
				try {
					onClickChooseFromGallery();
				} catch (Exception e) {
					Toast.makeText(getActivity(),
							getString(R.string.err_open_gallery),
							Toast.LENGTH_LONG).show();
				}
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
								.bitmapConfig(Config.RGB_565)
								.imageScaleType(
										ImageScaleType.IN_SAMPLE_POWER_OF_2)
								.build());
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