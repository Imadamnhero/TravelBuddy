package sdc.ui.fragment;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.ViewGroup;

public abstract class BaseFragment extends Fragment {

	@Override
	public void onActivityCreated(Bundle savedInstanceState) {
		super.onActivityCreated(savedInstanceState);
		initComponents();
		addListener();
		preLoadData();
	}

	protected abstract void initComponents();

	protected abstract void addListener();
	
	public abstract void preLoadData();

	@Override
	public void onDestroyView() {
		((ViewGroup) getView().getParent()).removeView(getView());
		super.onDestroyView();
	}

	@Override
	public void onResume() {
		super.onResume();
	}

}
