package sdc.ui.fragment;

import sdc.travelapp.R;
import sdc.ui.travelapp.MainActivity;
import sdc.ui.travelapp.MainActivity.Screen;
import android.os.Bundle;
import android.view.View;

public abstract class BaseHomeFragment extends BaseFragment {

	@Override
	public void onActivityCreated(Bundle savedInstanceState) {
		super.onActivityCreated(savedInstanceState);
	}

	@Override
	protected void addListener() {
		getView().findViewById(R.id.title_btn_menu).setOnClickListener(
				new View.OnClickListener() {
					@Override
					public void onClick(View v) {
						((MainActivity) getActivity()).openOrCloseNavi();
					}
				});
		getView().findViewById(R.id.title_btn_about).setOnClickListener(
				new View.OnClickListener() {
					@Override
					public void onClick(View v) {
						((MainActivity) getActivity())
								.changeScreen(Screen.ABOUT);
					}
				});
	}

}
