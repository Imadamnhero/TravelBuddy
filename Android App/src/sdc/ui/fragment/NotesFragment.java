package sdc.ui.fragment;

import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;

import sdc.application.TravelPrefs;
import sdc.data.Note;
import sdc.data.User;
import sdc.data.database.ContentProviderDB;
import sdc.data.database.adapter.NoteTableAdapter;
import sdc.data.database.adapter.UserTableAdapter;
import sdc.data.database.adapter.VersionTableAdapter;
import sdc.net.utils.JSONParseUtils;
import sdc.net.webservice.SyncNotesWS;
import sdc.travelapp.R;
import sdc.ui.adapter.ListNoteAdapter;
import sdc.ui.customview.AddNoteDialog;
import sdc.ui.travelapp.MainActivity;
import sdc.ui.utils.SetupSwipeListViewUtils;
import android.os.Bundle;
import android.util.Pair;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.fortysevendeg.swipelistview.SwipeListView;

public class NotesFragment extends BaseTripFragment {
	public static final String TITLE = "Notes";
	private SwipeListView lvNote;
	private ListNoteAdapter mAdapter;
	private List<Note> mData;
	private View navBtnRight;

	public NotesFragment() {
		super(TITLE);
	}

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		View root = inflater.inflate(R.layout.fragment_notes, container, false);
		return root;
	}

	@Override
	protected void addListener() {
		super.addListener();
		getView().findViewById(R.id.btn_addnew).setOnClickListener(
				new View.OnClickListener() {
					@Override
					public void onClick(View v) {
						new AddNoteDialog(getActivity(), NotesFragment.this)
								.show();
					}
				});
	}

	@Override
	protected void initComponents() {
		lvNote = (SwipeListView) getView().findViewById(R.id.swipe_lv_list);
		mData = new ArrayList<Note>();
		mAdapter = new ListNoteAdapter(getActivity(), mData);
		lvNote.setAdapter(mAdapter);
		SetupSwipeListViewUtils.setup(lvNote, getActivity());
		navBtnRight = getView().findViewById(R.id.title_btn_right);
		navBtnRight.setVisibility(View.VISIBLE);
		navBtnRight.setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View v) {
				syncNoteData((MainActivity) getActivity());
			}
		});
	}

	@Override
	public void preLoadData() {
		int tripId = (Integer) TravelPrefs.getData(getActivity(),
				TravelPrefs.PREF_TRIP_ID);
		mData.clear();
		List<Note> listNote = new NoteTableAdapter(getActivity())
				.getNotesInATrip(tripId);
		if (listNote != null)
			mData.addAll(listNote);
		// get owner info for each of note
		List<Integer> listUserId = new ArrayList<Integer>();
		for (Note data : mData)
			listUserId.add(data.getOwnerId());
		List<User> listUserInfo = new UserTableAdapter(getActivity())
				.getUsersFromUserIds(listUserId);
		if (mData.size() == listUserInfo.size())
			for (int i = 0; i < mData.size(); i++) {
				mData.get(i).setOwnerInfo(listUserInfo.get(i));
			}
		mAdapter.notifyDataSetChanged();
	}

	// This Variable use to fix bug happen when slow connection, while a row is
	// uploading, user upload that row again which make data is duplicated
	private static List<Integer> sIdsUploading = new LinkedList<Integer>();

	public static void clearUploading(
			List<Pair<Integer, Integer>> listIdUploaded) {
		for (Pair<Integer, Integer> pair : listIdUploaded)
			sIdsUploading.remove(pair.first);
	}

	public static void syncNoteData(MainActivity context) {
		int userId = (Integer) TravelPrefs.getData(context,
				TravelPrefs.PREF_USER_ID);
		int tripId = (Integer) TravelPrefs.getData(context,
				TravelPrefs.PREF_TRIP_ID);
		int noteVer = new VersionTableAdapter(context).getVersionTableofUser(
				userId, ContentProviderDB.COL_VERSION_NOTE);
		List<Note> listNote = new NoteTableAdapter(context)
				.getNotesNeedUpload();
		if (listNote != null)
			for (int i = 0; i < listNote.size(); i++) {
				int id = listNote.get(i).getId();
				boolean isRemove = false;
				for (int uploading : sIdsUploading) {
					if (uploading == id)
						isRemove = true;
				}
				if (isRemove) {
					listNote.remove(i);
					i--;
				} else
					sIdsUploading.add(id);
			}
		SyncNotesWS notesWS = SyncNotesWS.getInstance();
		if (!notesWS.isLoading()) {
			notesWS.fetchData(context, noteVer,
					JSONParseUtils.convertNoteToJSONArray(listNote), tripId);
		}
	}

}
