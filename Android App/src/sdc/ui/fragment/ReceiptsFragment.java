package sdc.ui.fragment;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import sdc.application.TravelApplication;
import sdc.application.TravelPrefs;
import sdc.data.Photo;
import sdc.data.database.ContentProviderDB;
import sdc.data.database.adapter.PhotoTableAdapter;
import sdc.net.webservice.SyncPhotosWS;
import sdc.travelapp.R;
import sdc.ui.adapter.ListReceiptAdapter;
import sdc.ui.customview.CustomSingleChoiceDialog;
import sdc.ui.travelapp.MainActivity;
import sdc.ui.utils.DateTimeUtils;
import sdc.ui.utils.StringUtils;
import sdc.ui.utils.Utils;
import android.app.Activity;
import android.app.ProgressDialog;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
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
import android.util.Base64;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.GridView;
import android.widget.TextView;
import android.widget.Toast;

import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.process.BitmapProcessor;

public class ReceiptsFragment extends BaseTripFragment implements
		View.OnClickListener {
	public static final String TITLE = "Receipts";
	private GridView mGridView;
	private TextView tvNoReceipt;
	private Button btnAdd, btnSend;
	private EditText et_mail;
	public List<Photo> arrReceipt;
	private Uri mImageCaptureUri;
	private static final int CAPTURE_IMAGE = 100;
	private static final int SELECT_PICTURE = 101;
	private String myImagePath;
	private ListReceiptAdapter mAdapter;
	private MainActivity mContext;
	private CheckBox mCheckbox;

	private BroadcastReceiver uploadPhotoBroadcastReceiver = new BroadcastReceiver() {
		@Override
		public void onReceive(Context context, Intent intent) {
			Photo photo = (Photo) intent.getSerializableExtra("photo");
			if (photo != null && mAdapter != null) {
				try {
					if (intent.getBooleanExtra("success", false)) {
						for (int i = 0; i < mAdapter.getCount(); i++) {
							if (mAdapter.getItem(i).getId() == photo.getId()) {
								mAdapter.getItem(i).setServerId(photo.getId());
								mAdapter.getItem(i).setUrlImage(
										photo.getUrlImage());
								break;
							}
						}
					}
					mAdapter.notifyDataSetChanged();
				} catch (Exception e) {

				}
			}

		}
	};

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		getActivity().registerReceiver(uploadPhotoBroadcastReceiver,
				new IntentFilter(SyncPhotosWS.FILTER_UPLOAD_PHOTO));
	}

	@Override
	public void onDestroy() {
		getActivity().unregisterReceiver(uploadPhotoBroadcastReceiver);
		super.onDestroy();
	}

	public ReceiptsFragment() {
		super(TITLE);
	}

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		View root = inflater.inflate(R.layout.fragment_receipts, container,
				false);
		mContext = (MainActivity) getActivity();
		return root;
	}

	@Override
	public void onResume() {
		super.onResume();
		preLoadData();
	}

	@Override
	protected void addListener() {
		btnAdd.setOnClickListener(this);
		btnSend.setOnClickListener(this);
		super.addListener();
	}

	@Override
	protected void initComponents() {
		mGridView = (GridView) getView().findViewById(R.id.gridView1);
		arrReceipt = new ArrayList<Photo>();
		mAdapter = new ListReceiptAdapter(getActivity(), arrReceipt, getView()
				.findViewById(R.id.tv_instruction));
		mGridView.setAdapter(mAdapter);
		btnAdd = (Button) getView().findViewById(R.id.btn_add_receipt);
		btnSend = (Button) getView().findViewById(R.id.btnSend);
		tvNoReceipt = (TextView) getView().findViewById(R.id.tvNoReceipt);
		et_mail = (EditText) getView().findViewById(R.id.et_mail);
		mCheckbox = (CheckBox) getView().findViewById(R.id.cb1_myself);
	}

	@Override
	public void preLoadData() {
		arrReceipt.removeAll(arrReceipt);
		arrReceipt.addAll(new PhotoTableAdapter(getActivity())
				.getAllReceiptsOfUser(mContext.getUserId(),
						mContext.getTripId()));
		if (arrReceipt.size() <= 0) {
			tvNoReceipt.setVisibility(View.VISIBLE);
		} else {
			tvNoReceipt.setVisibility(View.GONE);
		}
		mAdapter.notifyDataSetChanged();
	}

	@Override
	public void onClick(View v) {
		if (v == btnAdd) {
			try {
				showDialogPhoto(getString(R.string.choose_picture_title));
			} catch (Exception e) {
			}
		}
		if (v == btnSend) {
			if (arrReceipt.size() > 0
					&& !et_mail.getText().toString().equals("")) {

				if (!StringUtils.isEmailValid(et_mail.getText().toString())) {
					Toast.makeText(getActivity(),
							getString(R.string.toast_invalidate_sendmail),
							Toast.LENGTH_SHORT).show();
				} else {
					mContext.showSendReceiptFragment(et_mail.getText()
							.toString(), mCheckbox.isChecked());
				}

			} else {
				if (arrReceipt.size() <= 0) {
					Toast.makeText(getActivity(),
							getString(R.string.toast_receipt_nophoto),
							Toast.LENGTH_LONG).show();
				} else if (et_mail.getText().toString().equals("")) {
					Toast.makeText(getActivity(),
							getString(R.string.toast_receipt_nomail),
							Toast.LENGTH_LONG).show();
				} else {
					Toast.makeText(getActivity(),
							getString(R.string.toast_invalid_mail),
							Toast.LENGTH_LONG).show();
				}
			}
		}

	}

	@Override
	public void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);
		if (resultCode == Activity.RESULT_OK) {
			switch (requestCode) {
			case CAPTURE_IMAGE:
				// onSaved(myImagePath);
				saveFile(myImagePath);
				// myImagePath = null;
				break;
			case SELECT_PICTURE:
				// myDialog.dismiss();
				// onSaved(getRealPathFromURI(data.getData()));
				saveFile(getRealPathFromURI(data.getData()));
				break;
			}

		}
	}

	private void onSaved(String filePath) {
		Photo newPhoto = new Photo(-1, filePath,
				DateTimeUtils.formatDateForReceipt(mContext),
				mContext.getUserId(), mContext.getTripId(), true, 0,
				ContentProviderDB.FLAG_ADD);
		int newId = new PhotoTableAdapter(mContext).addPhoto(newPhoto,
				newPhoto.getTripId(), 0, newPhoto.getFlag());
		// upload to server
		newPhoto.setId(newId);
		if (TravelApplication.isOnline(mContext))
			SyncPhotosWS.doUpload(mContext.getApplicationContext(),
					(Integer) TravelPrefs.getData(mContext,
							TravelPrefs.PREF_USER_ID), mContext.getTripId());
		// fix bug UI uploading synchronize
		mAdapter.add(newPhoto);
		mAdapter.notifyDataSetChanged();
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
				inImage, "Title", null);
		return Uri.parse(path);
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
		File file = new File(getActivity().getExternalFilesDir("photos"),
				"photo_" + System.currentTimeMillis() + ".jpg");
		myImagePath = file.getAbsolutePath();
		mImageCaptureUri = Uri.fromFile(file);
		takePictureIntent.putExtra(android.provider.MediaStore.EXTRA_OUTPUT,
				mImageCaptureUri);
		takePictureIntent.putExtra("return-data", false);
		takePictureIntent.putExtra(MediaStore.EXTRA_FINISH_ON_COMPLETION, true);
		startActivityForResult(takePictureIntent, CAPTURE_IMAGE);
	}

	public void onClickChooseFromGallery() {
		Intent intent_gallery = new Intent(Intent.ACTION_PICK,
				android.provider.MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
		startActivityForResult(intent_gallery, SELECT_PICTURE);

	}

	public String BitMapToString(Bitmap bitmap) {
		ByteArrayOutputStream ByteStream = new ByteArrayOutputStream();
		bitmap.compress(Bitmap.CompressFormat.JPEG, 100, ByteStream);
		byte[] b = ByteStream.toByteArray();
		String temp = Base64.encodeToString(b, Base64.DEFAULT);
		return temp;
	}

	private void saveFile(String source) {
		if (new File(source).exists()) {
			new AsyncTask<String, Void, String>() {
				private ProgressDialog mDialog;

				protected void onPreExecute() {
					File file = new File(getActivity().getExternalFilesDir(
							"photos"), "photo_" + System.currentTimeMillis()
							+ ".jpg");
					myImagePath = file.getAbsolutePath();
					mDialog = new ProgressDialog(mContext);
					mDialog.setMessage("Saving...");
					mDialog.setOnCancelListener(new DialogInterface.OnCancelListener() {

						@Override
						public void onCancel(DialogInterface dialog) {
							cancel(true);
							try {
								File file = new File(myImagePath);
								if (file.exists()) {
									file.delete();
								}
							} catch (Exception e) {

							}
						}
					});
					mDialog.show();
				};

				protected String doInBackground(String... params) {
					try {
						// if (params[0].endsWith("jpg")
						// || params[0].endsWith(".jpeg")) {
						// DownloadFileFromURLTask.copyFile(params[0],
						// myImagePath);
						// } else {
						// System.gc();
						// Bitmap bitmap = Utils.decodeSampledBitmapFromFile(
						// params[0], 800, 800);
						// bitmap.compress(CompressFormat.JPEG, 100,
						// new FileOutputStream(new File(myImagePath)));
						// bitmap.recycle();
						// bitmap = null;
						// }
						@SuppressWarnings("deprecation")
						final int screenWidth = getActivity()
								.getWindowManager().getDefaultDisplay()
								.getWidth();
						@SuppressWarnings("deprecation")
						final int screenHeight = getActivity()
								.getWindowManager().getDefaultDisplay()
								.getHeight();
						try {
							Bitmap bitmap = Utils.decodeSampledBitmapFromFile(
									params[0], screenWidth, screenHeight);
							if (bitmap != null) {
								bitmap.compress(CompressFormat.JPEG, 100,
										new FileOutputStream(myImagePath));
							}else{
								mContext.runOnUiThread(new Runnable() {

									@Override
									public void run() {
										Toast.makeText(mContext,
												"Cannot save file",
												Toast.LENGTH_LONG).show();
									}
								});
							}
						} catch (OutOfMemoryError e) {
							try {
								Utils.copyFile(new File(params[0]), new File(
										myImagePath));
							} catch (IOException ex) {
								mContext.runOnUiThread(new Runnable() {

									@Override
									public void run() {
										Toast.makeText(mContext,
												"Cannot save file",
												Toast.LENGTH_LONG).show();
									}
								});
							}
						}
						return myImagePath;
					} catch (IOException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					} catch (OutOfMemoryError e) {
						mContext.runOnUiThread(new Runnable() {

							@Override
							public void run() {
								Toast.makeText(mContext, "Out of Memory",
										Toast.LENGTH_LONG).show();
							}
						});
					}
					return null;
				};

				protected void onPostExecute(String result) {
					if (mDialog.isShowing()) {
						mDialog.dismiss();
					}
					if (result == null) {
						File file = new File(myImagePath);
						if (file.exists()) {
							file.delete();
						}
					} else {
						onSaved(myImagePath);
						myImagePath = null;
					}
				};

			}.execute(source);
		} else {
			Toast.makeText(mContext, "File does not exist", Toast.LENGTH_LONG)
					.show();
		}
	}
}
