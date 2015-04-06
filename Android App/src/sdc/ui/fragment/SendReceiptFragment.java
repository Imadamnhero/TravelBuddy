package sdc.ui.fragment;

import java.util.ArrayList;
import java.util.List;

import sdc.data.Photo;
import sdc.data.database.adapter.PhotoTableAdapter;
import sdc.net.webservice.SendReceiptWS;
import sdc.travelapp.R;
import sdc.ui.adapter.SendReceiptAdapter;
import sdc.ui.travelapp.MainActivity;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.GridView;
import android.widget.Toast;

public class SendReceiptFragment extends BaseTripFragment implements
		View.OnClickListener {
	public static final String TITLE = "Send Receipts";
	private SendReceiptAdapter mGridAdapter;
	private List<Photo> mListPhoto;
	private List<Photo> mListChoosenPhoto;
	private MainActivity mContext;
	private String email;
	private boolean sendToOwner;

	public void setEmail(String email) {
		this.email = email;
	}

	public void setSendToOwner(boolean sendToOwner) {
		this.sendToOwner = sendToOwner;
	}

	public SendReceiptFragment() {
		super(TITLE);
	}

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		View root = inflater.inflate(R.layout.fragment_send_receipt, container,
				false);
		mContext = (MainActivity) getActivity();
		return root;
	}

	@Override
	protected void initComponents() {
		mListPhoto = new ArrayList<Photo>();
		mListChoosenPhoto = new ArrayList<Photo>();
		mGridAdapter = new SendReceiptAdapter(getActivity(), mListPhoto, this);
		((GridView) getView().findViewById(R.id.gridview))
				.setAdapter(mGridAdapter);
	}

	@Override
	public void preLoadData() {
		mGridAdapter.reloadPhoto(new PhotoTableAdapter(mContext)
				.getAllReceiptsOfUser(mContext.getUserId(),
						mContext.getTripId()));
	}

	@Override
	protected void addListener() {
		super.addListener();
		getView().findViewById(R.id.title_btn_menu).setOnClickListener(this);
		getView().findViewById(R.id.btn_send).setOnClickListener(this);
	}

	@Override
	public void onClick(View v) {
		switch (v.getId()) {
		case R.id.title_btn_menu:
			getActivity().onBackPressed();
			break;
		case R.id.btn_send:
			if (mListChoosenPhoto.size() == 0) {
				Toast.makeText(getActivity(),
						"You must select at least one photo", Toast.LENGTH_LONG)
						.show();
			} else {
				String ids = "";
				for (Photo photo : mListChoosenPhoto) {
					if (ids.length() == 0) {
						ids += photo.getServerId();
					} else {
						ids += "," + photo.getServerId();
					}
				}
				mContext.showProgressDialog(
						getString(R.string.title_send_receipt),
						getString(R.string.wait_in_sec), null);
				new SendReceiptWS(mContext).fetchData(mContext.getUserId(),
						email.toString(), sendToOwner ? 1 : 0, ids);
			}
			break;
		}
	}

	public void addPhotoToClip(int pos) {
		mListChoosenPhoto.add(mListPhoto.get(pos));
	}

	public void removePhotoToClip(int pos) {
		int id = mListPhoto.get(pos).getId();
		for (int i = 0; i < mListChoosenPhoto.size(); i++) {
			if (mListChoosenPhoto.get(i).getId() == id) {
				mListChoosenPhoto.remove(i);
			}
		}
	}

}
