package sdc.ui.activity;

import java.util.List;

import sdc.application.TravelPrefs;
import sdc.data.Photo;
import sdc.data.database.adapter.PhotoTableAdapter;
import sdc.travelapp.R;
import sdc.ui.adapter.FullScreenImageAdapter;
import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.view.ViewPager;

public class FullScreenViewActivity extends Activity {
	private ViewPager viewPager;
	private FullScreenImageAdapter adapter;
	private List<Photo> listPhoto;
	private FullScreenImageAdapter.OnRemovePhotoListener mListener = new FullScreenImageAdapter.OnRemovePhotoListener() {

		@Override
		public void onRemoved() {
			adapter = new FullScreenImageAdapter(FullScreenViewActivity.this,
					listPhoto, mListener);
			viewPager.setAdapter(adapter);
			if (adapter.getCount() == 0) {
				finish();
			}
		}
	};

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_full_screen_view);
		viewPager = (ViewPager) findViewById(R.id.pager);
		Intent i = getIntent();
		int position = i.getIntExtra("position", 0);
		listPhoto = new PhotoTableAdapter(this)
				.getAllPhotoOfTrip((Integer) TravelPrefs.getData(this,
						TravelPrefs.PREF_TRIP_ID));
		adapter = new FullScreenImageAdapter(FullScreenViewActivity.this,
				listPhoto, mListener);
		viewPager.setAdapter(adapter);
		viewPager.setCurrentItem(position);
	}

}
