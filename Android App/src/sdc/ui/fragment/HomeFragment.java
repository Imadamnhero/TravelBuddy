package sdc.ui.fragment;

import sdc.travelapp.R;
import sdc.ui.travelapp.MainActivity;
import sdc.ui.travelapp.MainActivity.Screen;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

public class HomeFragment extends BaseHomeFragment implements
		View.OnClickListener {

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		View root = inflater.inflate(R.layout.fragment_home, container, false);
		return root;
	}

	@Override
	protected void initComponents() {
		ExpensesFragment.syncExpenseCategories((MainActivity) getActivity());
	}

	@Override
	protected void addListener() {
		super.addListener();
		getView().findViewById(R.id.btn_addtrip).setOnClickListener(this);
	}

	@Override
	public void onClick(View v) {
		MainActivity mother = ((MainActivity) getActivity());
		if (v.getId() == R.id.btn_addtrip) {
			mother.changeScreen(Screen.ADD_TRIP);
		} else if (v.getId() == R.id.title_btn_menu) {
			mother.openOrCloseNavi();
			getActivity();

		}
	}

	@Override
	public void preLoadData() {
		// TODO Auto-generated method stub

	}

}
