package sdc.ui.fragment;

import sdc.travelapp.R;
import sdc.ui.travelapp.MainActivity;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;

public class AboutFragment extends BaseHomeFragment {
	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		View root = inflater.inflate(R.layout.fragment_about, container, false);

		return root;
	}

	@Override
	protected void addListener() {
		super.addListener();
		getView().findViewById(R.id.btn_close).setOnClickListener(
				new OnClickListener() {
					@Override
					public void onClick(View v) {
						((MainActivity) getActivity()).onBackPressed();
					}
				});
	}
	
	@Override
	public void preLoadData() {
	}

	@Override
	protected void initComponents() {
		getView().findViewById(R.id.title_btn_menu).setVisibility(View.GONE);
	}
}
