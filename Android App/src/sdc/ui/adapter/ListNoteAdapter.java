package sdc.ui.adapter;

import java.util.List;

import sdc.application.TravelPrefs;
import sdc.data.Note;
import sdc.data.database.adapter.NoteTableAdapter;
import sdc.net.webservice.BaseWS;
import sdc.travelapp.R;
import sdc.ui.fragment.NotesFragment;
import sdc.ui.travelapp.MainActivity;
import sdc.ui.utils.DateTimeUtils;
import android.content.Context;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.assist.ImageScaleType;

public class ListNoteAdapter extends BaseArrayAdapter<Note> {
	private DisplayImageOptions options = new DisplayImageOptions.Builder()
			.cacheInMemory(true).cacheOnDisc(true)
			.showImageOnLoading(R.drawable.home_bg)
			.imageScaleType(ImageScaleType.IN_SAMPLE_POWER_OF_2)
			.showImageOnFail(R.drawable.home_bg).build();
	private int mUserId;

	@Override
	public boolean isEnabled(int position) {
		return getItem(position).getOwnerId() == mUserId;
	}

	public ListNoteAdapter(Context context, List<Note> data) {
		super(context, R.layout.row_list_note, data);
		mUserId = (Integer) TravelPrefs.getData(getContext(),
				TravelPrefs.PREF_USER_ID);
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		convertView = super.getView(position, convertView, parent);
		if (getCount() - 1 == position) {
			convertView.findViewById(R.id.front).setBackgroundResource(
					R.drawable.bg_row_has_corner);
			convertView.findViewById(R.id.back).setBackgroundResource(
					R.drawable.bg_row_deleting_corner);
		}
		TextView tv1, tv2, tv3;
		tv1 = (TextView) convertView.findViewById(R.id.textView1);
		tv2 = (TextView) convertView.findViewById(R.id.textView2);
		tv3 = (TextView) convertView.findViewById(R.id.textView3);
		Note note = getItem(position);
		tv1.setText(note.getTitle());
		tv2.setText(note.getContent());
		if (note.getOwnerInfo() != null) {
			if (note.getOwnerId() == mUserId) {
				tv3.setText(DateTimeUtils.formatFooterForNote("you",
						note.getTime()));
			} else {
				tv3.setText(DateTimeUtils.formatFooterForNote(note
						.getOwnerInfo().getName(), note.getTime()));
			}
			ImageView img = (ImageView) convertView
					.findViewById(R.id.img_group);
			ImageLoader.getInstance()
					.displayImage(
							BaseWS.HOST + note.getOwnerInfo().getAvatar(), img,
							options);
		}
		return convertView;
	}

	// @Override
	// public void removeItem(int position) {
	// Context context = getContext();
	// new NoteTableAdapter(context).deleteOfflineUponId(getItem(position)
	// .getId());
	// if (context instanceof MainActivity) {
	// NotesFragment.syncNoteData((MainActivity) context);
	// }
	// super.removeItem(position);
	// }

	@Override
	public void remove(Note object) {
		super.remove(object);
		Context context = getContext();
		new NoteTableAdapter(context).deleteOfflineUponId(object.getId());
		if (context instanceof MainActivity) {
			NotesFragment.syncNoteData((MainActivity) context);
		}
	}

}
