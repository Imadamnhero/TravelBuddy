package sdc.ui.customview;

import java.util.ArrayList;
import java.util.List;

import sdc.data.Packing;
import sdc.data.PackingItem;
import sdc.data.database.adapter.PackingItemTableAdapter;
import sdc.travelapp.R;
import sdc.ui.adapter.ListItemNoSwipeAdapter;
import sdc.ui.adapter.PackingAdapter;
import sdc.ui.fragment.PackingFragment;
import sdc.ui.travelapp.MainActivity;
import android.app.Dialog;
import android.content.Context;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.view.View;
import android.view.Window;
import android.widget.ListView;
import android.widget.TextView;

public class ListItemDialog extends Dialog implements View.OnClickListener {
	private Packing mData;
	private ListView mListView;
	private List<PackingItem> mBackupData;
	private PackingAdapter mCallBack;
	private Context mContext;

	public ListItemDialog(Context context, Packing data, PackingAdapter callBack) {
		super(context);
		mData = data;
		// clone data to backup if cancel
		mBackupData = new ArrayList<PackingItem>();
		for (PackingItem item : mData.getListItem())
			mBackupData.add(item.clone());
		mCallBack = callBack;
		mContext = context;
	}

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.dialog_listitem);
		this.getWindow().setBackgroundDrawable(
				new ColorDrawable(android.graphics.Color.TRANSPARENT));
		setCancelable(false);
		findViewById(R.id.btn_left).setOnClickListener(this);
		findViewById(R.id.btn_right).setOnClickListener(this);
		TextView title = (TextView) findViewById(R.id.tv_title);
		title.setText(mData.getTitle());
		mListView = (ListView) findViewById(R.id.listView1);
		mListView.setAdapter(new ListItemNoSwipeAdapter(getContext(), mData
				.getListItem()));
	}

	@Override
	public void onClick(View v) {
		switch (v.getId()) {
		case R.id.btn_left:
			new PackingItemTableAdapter(getContext()).updateCheckItems(mData
					.getListItem());
			mData.calculatePercent();
			mCallBack.notifyDataSetChanged();
			PackingFragment.syncPackingItem((MainActivity) mContext);
			dismiss();
			break;
		case R.id.btn_right:
			List<PackingItem> listItem = mData.getListItem();
			if (listItem != null) {
				listItem.removeAll(listItem);
				listItem.addAll(mBackupData);
			}
			dismiss();
			break;
		default:
			break;
		}
	}
}