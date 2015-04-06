package sdc.ui.fragment;

import java.util.ArrayList;
import java.util.List;

import sdc.application.TravelPrefs;
import sdc.data.User;
import sdc.data.database.ContentProviderDB;
import sdc.data.database.adapter.UserTableAdapter;
import sdc.data.database.adapter.UsersInGroupTableAdapter;
import sdc.data.database.adapter.VersionTableAdapter;
import sdc.net.webservice.GetUsersInGroupWS;
import sdc.travelapp.R;
import sdc.ui.adapter.ListGroupAdapter;
import sdc.ui.travelapp.MainActivity;
import sdc.ui.travelapp.MainActivity.Screen;
import android.os.Bundle;
import android.util.Pair;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ListView;


public class GroupFragment extends BaseTripFragment {
	public static final String TITLE = "Group";
	private ListView mListView;
	private List<Pair<User, Boolean>> mListUsers;
	private int mTripId;
	private int mUserId;

	public GroupFragment() {
		super(TITLE);
	}

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		View root = inflater.inflate(R.layout.fragment_group, container, false);
		return root;
	}

	@Override
	protected void addListener() {
		super.addListener();
		getView().findViewById(R.id.btn1).setOnClickListener(
				new View.OnClickListener() {
					@Override
					public void onClick(View v) {
						((MainActivity) getActivity())
								.changeScreen(Screen.INVITE);
					}
				});
		;
	}

	@Override
	protected void initComponents() {
		mListView = (ListView) getView().findViewById(
				R.id.swipe_lv_list);
		//SetupSwipeListViewUtils.setup(mSwipeListView, getActivity());
	}

	@Override
	public void preLoadData() {
		mTripId = (Integer) TravelPrefs.getData(getActivity(),
				TravelPrefs.PREF_TRIP_ID);
		mUserId = (Integer) TravelPrefs.getData(getActivity(),
				TravelPrefs.PREF_USER_ID);
		mListUsers = new ArrayList<Pair<User, Boolean>>();
		List<Pair<Integer, Boolean>> listUserInGroup = new UsersInGroupTableAdapter(
				getActivity()).getFriendInATrip(mTripId, mUserId);
		if (listUserInGroup != null) {
			List<Integer> listUserId = new ArrayList<Integer>();
			for (Pair<Integer, Boolean> pair : listUserInGroup)
				listUserId.add(pair.first);
			List<User> listUserInfo = new UserTableAdapter(getActivity())
					.getUsersFromUserIds(listUserId);
			for (int i = 0; i < listUserInfo.size(); i++)
				mListUsers.add(new Pair<User, Boolean>(listUserInfo.get(i),
						listUserInGroup.get(i).second));
		}
		mListView.setAdapter(new ListGroupAdapter(getActivity(),
				mListUsers));
	}

	public static void getUsersInGroup(MainActivity context) {
		int clientVer = new VersionTableAdapter(context).getVersionTableofUser(
				context.getUserId(), ContentProviderDB.COL_VERSION_GROUP);
		new GetUsersInGroupWS(context, context).fetchData(context.getTripId(),
				clientVer);
	}
}
