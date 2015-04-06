package sdc.ui.fragment;

import java.util.List;

import sdc.data.SlideShow;
import sdc.data.database.adapter.SlideShowTableAdapter;
import sdc.travelapp.R;
import sdc.ui.adapter.ReviewVideoAdapter;
import sdc.ui.customview.SlideShowActionDialog;
import sdc.ui.travelapp.MainActivity;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.GridView;

public class ReviewSlideShowFragment extends BaseTripFragment {
	public static final String TITLE = "My Slideshows";
	private GridView mGridView;
	private MainActivity mContext;
	private ReviewVideoAdapter mVideoAdapter;
	private List<SlideShow> mData; // list local video path

	public ReviewSlideShowFragment() {
		super(TITLE);
	}

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		View root = inflater.inflate(R.layout.fragment_review_slideshow,
				container, false);
		mContext = (MainActivity) getActivity();
		mGridView = (GridView) root.findViewById(R.id.gridview);
		return root;
	}

	@Override
	protected void initComponents() {
		mData = new SlideShowTableAdapter(mContext).getAll(
				mContext.getTripId(), mContext.getUserId());
		mVideoAdapter = new ReviewVideoAdapter(getActivity(), mData);
		mGridView.setAdapter(mVideoAdapter);
		mGridView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
			@Override
			public void onItemClick(AdapterView<?> parent, View view,
					int position, long id) {
				new SlideShowActionDialog(mContext, mData.get(position),
						new SlideShowActionDialog.DeleteSlideShowListener() {

							@Override
							public void onDelete(SlideShow slideShow) {
								mData.remove(slideShow);
								mVideoAdapter.notifyDataSetChanged();
							}
						}).show();
			}
		});
		if (mVideoAdapter.getCount() == 0) {
			getView().findViewById(R.id.tv_no_data).setVisibility(View.VISIBLE);
		} else {
			getView().findViewById(R.id.tv_no_data).setVisibility(View.GONE);
		}
	}

	@Override
	protected void addListener() {
		super.addListener();
		changeBtnMenuToBack("");
	}

	@Override
	public void preLoadData() {
	}

	// @Override
	// public void onCreateContextMenu(ContextMenu menu, View v,
	// ContextMenuInfo menuInfo) {
	// super.onCreateContextMenu(menu, v, menuInfo);
	// if (v.getId() == R.id.gridview) {
	// MenuInflater inflater = mContext.getMenuInflater();
	// inflater.inflate(R.menu.menu_slideshow, menu);
	// }
	// }

	// @Override
	// public boolean onContextItemSelected(MenuItem item) {
	// AdapterContextMenuInfo info = (AdapterContextMenuInfo) item
	// .getMenuInfo();
	// switch (item.getItemId()) {
	// case R.id.menu_del:
	// File file = new File(mData.get(info.position));
	// file.delete();
	// mVideoAdapter.notifyDataSetChanged();
	// return true;
	// case R.id.menu_share:
	// Intent emailIntent = new Intent(android.content.Intent.ACTION_SEND);
	// emailIntent.setType("video/*");
	// // emailIntent.putExtra(android.content.Intent.EXTRA_EMAIL,
	// // new String[] { "me@gmail.com" });
	// String tripName = (String) TravelPrefs.getData(mContext,
	// TravelPrefs.PREF_TRIP_NAME);
	// emailIntent.putExtra(android.content.Intent.EXTRA_SUBJECT,
	// getString(R.string.subject_slideshow, tripName));
	// emailIntent.putExtra(android.content.Intent.EXTRA_TEXT,
	// getString(R.string.content_slideshow_attach, tripName));
	// emailIntent.putExtra(Intent.EXTRA_STREAM,
	// Uri.fromFile(new File(mData.get(info.position))));
	// startActivity(Intent.createChooser(emailIntent,
	// "Send your slideshow..."));
	// return true;
	// default:
	// return super.onContextItemSelected(item);
	// }
	// }
}
