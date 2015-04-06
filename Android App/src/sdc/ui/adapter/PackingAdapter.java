package sdc.ui.adapter;

import java.util.List;

import sdc.data.Packing;
import sdc.data.database.adapter.PackingTitleTableAdapter;
import sdc.travelapp.R;
import sdc.ui.customview.ListItemDialog;
import sdc.ui.fragment.PackingFragment;
import sdc.ui.travelapp.MainActivity;
import sdc.ui.view.PercentCycleView;
import android.content.Context;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

public class PackingAdapter extends BaseArrayAdapter<Packing> {

	public PackingAdapter(Context context, List<Packing> data) {
		super(context, R.layout.row_packing, data);
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		convertView = super.getView(position, convertView, parent);
		if (position == getCount() - 1) {
			convertView.findViewById(R.id.front).setBackgroundResource(
					R.drawable.bg_row_has_corner);
			convertView.findViewById(R.id.back).setBackgroundResource(
					R.drawable.bg_row_deleting_corner);
		}
		TextView type = (TextView) convertView.findViewById(R.id.textView1);
		type.setText(getItem(position).getTitle());
		PercentCycleView cycle = (PercentCycleView) convertView
				.findViewById(R.id.cycle);
		cycle.setPercent(getItem(position).getPercent());
		convertView.findViewById(R.id.clickview).setOnClickListener(
				new RowClickListener(position));
		return convertView;
	}

	private class RowClickListener implements View.OnClickListener {
		private int mPosition;

		public RowClickListener(int pos) {
			mPosition = pos;
		}

		@Override
		public void onClick(View v) {
			if (getItem(mPosition).getListItem() != null)
				new ListItemDialog(getContext(), getItem(mPosition),
						PackingAdapter.this).show();
			else
				((MainActivity) getContext()).showToast(getContext().getString(
						R.string.toast_syncing_packing));
		}
	}

	// @Override
	// public void removeItem(int position) {
	// Context context = getContext();
	// new PackingTitleTableAdapter(context).deleteOfflinePackingUponId(
	// getItem(position).getId(), getItem(position).getServerId());
	// if (context instanceof MainActivity) {
	// PackingFragment.syncPackingTitle((MainActivity) context);
	// PackingFragment.syncPackingItem((MainActivity) context);
	// }
	// super.removeItem(position);
	// }

	@Override
	public void remove(Packing object) {
		super.remove(object);
		Context context = getContext();
		new PackingTitleTableAdapter(context).deleteOfflinePackingUponId(
				object.getId(), object.getServerId());
		if (context instanceof MainActivity) {
			PackingFragment.syncPackingTitle((MainActivity) context);
			PackingFragment.syncPackingItem((MainActivity) context);
		}
	}

}
