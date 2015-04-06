package sdc.ui.fragment;

import java.util.ArrayList;
import java.util.List;

import sdc.data.Photo;
import sdc.data.database.adapter.PhotoTableAdapter;
import sdc.net.webservice.SyncPhotosWS;
import sdc.travelapp.R;
import sdc.ui.adapter.CustomGrid;
import sdc.ui.customview.CustomChooseActionDialog;
import sdc.ui.travelapp.MainActivity;
import sdc.ui.travelapp.MainActivity.Screen;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.GridView;

public class SlideShowFragment extends BaseTripFragment implements
		View.OnClickListener {
	public static final String TITLE = "SlideShow";
	private GridView mGridView;
	private List<Photo> mListPhoto;
	private MainActivity mContext;
	private CustomGrid mGridAdapter;
	private BroadcastReceiver uploadPhotoBroadcastReceiver = new BroadcastReceiver() {
		@Override
		public void onReceive(Context context, Intent intent) {
			Photo photo = (Photo) intent.getSerializableExtra("photo");
			if (photo != null && mGridAdapter != null) {
				try {
					if (intent.getBooleanExtra("success", false)) {
						for (int i = 0; i < mGridAdapter.getCount(); i++) {
							if (mGridAdapter.getItem(i).getId() == photo
									.getId()) {
								mGridAdapter.getItem(i).setServerId(
										photo.getId());
								mGridAdapter.getItem(i).setUrlImage(
										photo.getUrlImage());
								break;
							}
						}
					}
					mGridAdapter.notifyDataSetChanged();
				} catch (Exception e) {

				}
			}

		}
	};

	// private SendVideoAdapter mSendAdapter;

	public SlideShowFragment() {
		super(TITLE);
	}

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		getActivity().registerReceiver(uploadPhotoBroadcastReceiver,
				new IntentFilter(SyncPhotosWS.FILTER_UPLOAD_PHOTO));
	}

	@Override
	public void onResume() {
		super.onResume();
		preLoadData();
	}

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		View root = inflater.inflate(R.layout.fragment_slideshow, container,
				false);
		mContext = (MainActivity) getActivity();
		mGridView = (GridView) root.findViewById(R.id.gridview);
		return root;
	}

	@Override
	protected void addListener() {
		super.addListener();
		getActivity().findViewById(R.id.tab1).setOnClickListener(this);
		getActivity().findViewById(R.id.tab2).setOnClickListener(this);
		// getActivity().findViewById(R.id.tab3).setOnClickListener(this);
	}

	@Override
	protected void initComponents() {
		mListPhoto = new ArrayList<Photo>();
		mGridAdapter = new CustomGrid(getActivity(), mListPhoto, getView()
				.findViewById(R.id.tv_no_data), getView().findViewById(
				R.id.tv_instruction));
		mGridView.setAdapter(mGridAdapter);
	}

	@Override
	public void preLoadData() {
		mListPhoto.clear();
		mListPhoto.addAll(new PhotoTableAdapter(mContext)
				.getAllPhotoOfTrip(mContext.getTripId()));
		mGridAdapter.notifyDataSetChanged();
	}

	@Override
	public void onClick(View v) {
		if (v.getId() == R.id.tab1) {
			mContext.changeScreen(Screen.CREATE_SLIDESHOW);
			// mContext.showToast(getString(R.string.toast_comming_soon));
		}
		if (v.getId() == R.id.tab2) {
			mContext.changeScreen(Screen.REVIEW_SLIDESHOW);
			// mContext.showToast(getString(R.string.toast_comming_soon));
		}
		// if (v.getId() == R.id.tab3) {
		// changeBtnMenuToBack();
		// mSendAdapter = new SendVideoAdapter(getActivity(),
		// getListMP4OfFiles(Configs.TRAVEL_VIDEO_PATH));
		// mGridView.setAdapter(mSendAdapter);
		// mContext.showToast(getString(R.string.toast_comming_soon));
		// }
	}

	@Override
	public void onDestroyView() {
		// SupportMapFragment f = (SupportMapFragment) getFragmentManager()
		// .findFragmentById(R.id.map);
		// if (f != null) {
		// try {
		// getFragmentManager().beginTransaction().remove(f).commit();
		// } catch (Exception e) {
		// e.printStackTrace();
		// }
		// }
		super.onDestroyView();
	}

	@Override
	public void onDestroy() {
		getActivity().unregisterReceiver(uploadPhotoBroadcastReceiver);
		super.onDestroy();
	}

	public void showActionDialog(String title) {
		final CustomChooseActionDialog dialog = new CustomChooseActionDialog(
				getActivity(), title, getString(R.string.choose_action_item1),
				getString(R.string.choose_action_item2),
				getString(R.string.choose_action_item3));
		dialog.getWindow().setBackgroundDrawable(
				new ColorDrawable(android.graphics.Color.TRANSPARENT));
		dialog.setOnClickTop(new CustomChooseActionDialog.OnClickLeft() {

			@Override
			public void Click() {
				dialog.dismiss();

			}
		});
		dialog.setOnClickCenter(new CustomChooseActionDialog.OnClickCenter() {

			@Override
			public void Click() {
				dialog.dismiss();

			}
		});
		dialog.setOnClickBottom(new CustomChooseActionDialog.OnClickRight() {

			@Override
			public void Click() {
				dialog.dismiss();

			}
		});
		try {
			dialog.show();
		} catch (Exception e) {

		}
		dialog.setTextBtn(getString(R.string.btn_cancel));
	}

}
