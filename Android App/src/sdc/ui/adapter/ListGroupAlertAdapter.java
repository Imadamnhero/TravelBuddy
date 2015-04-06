package sdc.ui.adapter;

import java.util.ArrayList;
import java.util.List;

import sdc.data.User;
import sdc.net.webservice.BaseWS;
import sdc.travelapp.R;
import sdc.ui.fragment.AlertFragment;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.CompoundButton.OnCheckedChangeListener;
import android.widget.ImageView;
import android.widget.TextView;

import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.assist.ImageScaleType;

public class ListGroupAlertAdapter extends ArrayAdapter<User> {
	private DisplayImageOptions options = new DisplayImageOptions.Builder()
			.cacheInMemory(true).cacheOnDisc(true)
			.showImageOnLoading(R.drawable.default_avatar)
			.imageScaleType(ImageScaleType.IN_SAMPLE_POWER_OF_2)
			.showImageOnFail(R.drawable.default_avatar).build();

	private List<User> mData;
	private boolean[] mChecking;
	private AlertFragment mCallBack;

	public ListGroupAlertAdapter(Context context, List<User> data) {
		super(context, R.layout.row_list_note, data);
		this.mData = data;
		mChecking = new boolean[mData.size()];
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		LayoutInflater inflater = LayoutInflater.from(getContext());
		convertView = inflater.inflate(R.layout.row_list_group_alert, parent,
				false);
		ImageView imageFr = (ImageView) convertView
				.findViewById(R.id.img_group2);
		TextView nameFr = (TextView) convertView.findViewById(R.id.textView1);
		CheckBox cb = (CheckBox) convertView.findViewById(R.id.cb1);
		ImageLoader.getInstance().displayImage(
				BaseWS.HOST + getItem(position).getAvatar(), imageFr, options);
		nameFr.setText(mData.get(position).getName());
		cb.setChecked(mChecking[position]);
		cb.setOnCheckedChangeListener(new MyCheckedChangeListener(position));
		if (mData.size() - 1 == position) {
			convertView.setBackgroundResource(R.drawable.bg_row_has_corner);
		}
		return convertView;
	}

	@Override
	public void notifyDataSetChanged() {
		super.notifyDataSetChanged();
		mChecking = new boolean[mData.size()];
	}

	@Override
	public int getCount() {
		return mData.size();
	}

	public void setChecking(int pos, boolean isCheck) {
		if (pos >= 0 && pos < mChecking.length)
			mChecking[pos] = isCheck;
		super.notifyDataSetChanged();
	}

	public void setCheckingAll(boolean isCheck) {
		for (int i = 0; i < mChecking.length; i++) {
			mChecking[i] = isCheck;
		}
		super.notifyDataSetChanged();
	}

	public boolean notcheckAny() {
		for (int i = 0; i < mChecking.length; i++) {
			if (mChecking[i] == true)
				return false;
		}
		return true;
	}

	public void setCallBack(AlertFragment frag) {
		mCallBack = frag;
	}
	
	public List<Integer> getIdIsChecking(){
		List<Integer> listId = new ArrayList<Integer>();
		for (int i=0; i< mChecking.length; i++) {
			if(mChecking[i])
				listId.add(mData.get(i).getId());
		}
		return listId;
	}

	private class MyCheckedChangeListener implements OnCheckedChangeListener {
		int mPosition;

		public MyCheckedChangeListener(int pos) {
			mPosition = pos;
		}

		@Override
		public void onCheckedChanged(CompoundButton buttonView,
				boolean isChecked) {
			mCallBack.setCheckBox(false);
			mChecking[mPosition] = isChecked;
		}
	}

}
