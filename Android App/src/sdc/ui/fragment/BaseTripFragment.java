package sdc.ui.fragment;

import sdc.travelapp.R;
import sdc.ui.customview.CustomDialog;
import sdc.ui.travelapp.MainActivity;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

public abstract class BaseTripFragment extends BaseFragment {
	private String mTitle;

	public BaseTripFragment(String title) {
		this.mTitle = title;
	}

	@Override
	public void onActivityCreated(Bundle savedInstanceState) {
		super.onActivityCreated(savedInstanceState);
		this.setTitle(mTitle);
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
	}

	public void setTitle(String title) {
		mTitle = title;
		if (getView() != null){
			TextView tvTitle = (TextView) getView().findViewById(R.id.title_trip);
			tvTitle.setText(mTitle);
			tvTitle.setSelected(true);
		}

	}

	public String getTitle() {
		return mTitle;
	}

	public void changeBtnMenuToBack(final String text) {
		ImageView btn = (ImageView) getView().findViewById(R.id.title_btn_menu);
		btn.setImageResource(R.drawable.btn_back);
		btn.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				if (!text.equals(""))
					showConfirmDialog(text);
				else {
					getActivity().onBackPressed();
				}
			}
		});
	}

	protected void showConfirmDialog(String text) {
		CustomDialog dialog = new CustomDialog(getActivity(), getActivity()
				.getString(R.string.choose_picture_title), text);
		dialog.getWindow().setBackgroundDrawable(
				new ColorDrawable(android.graphics.Color.TRANSPARENT));
		dialog.setOnClickLeft(new CustomDialog.OnClickLeft() {

			@Override
			public void click() {
				getActivity().onBackPressed();
			}
		});
		dialog.setOnClickRight(new CustomDialog.OnClickRight() {

			@Override
			public void click() {

			}
		});
		dialog.show();
		dialog.setTextBtn(getActivity().getString(R.string.btn_yes),
				getActivity().getString(R.string.btn_no));
	}
}
