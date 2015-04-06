package sdc.ui.fragment;

import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;

import sdc.data.Packing;
import sdc.data.PackingItem;
import sdc.data.database.ContentProviderDB;
import sdc.data.database.adapter.PackingItemTableAdapter;
import sdc.data.database.adapter.PackingTitleTableAdapter;
import sdc.data.database.adapter.PremadePackingItemTableAdapter;
import sdc.data.database.adapter.PremadePackingTitleTableAdapter;
import sdc.data.database.adapter.VersionTableAdapter;
import sdc.net.utils.JSONParseUtils;
import sdc.net.webservice.SyncPackingItemWS;
import sdc.net.webservice.SyncPackingWS;
import sdc.travelapp.R;
import sdc.ui.adapter.BaseArrayAdapter;
import sdc.ui.adapter.ListItemAdapter;
import sdc.ui.adapter.ListPreMadeAdapter;
import sdc.ui.adapter.PackingAdapter;
import sdc.ui.customview.AddItemDialog;
import sdc.ui.customview.CustomDialog;
import sdc.ui.travelapp.MainActivity;
import sdc.ui.travelapp.MainActivity.Screen;
import sdc.ui.utils.SetupSwipeListViewUtils;
import sdc.ui.utils.StringUtils;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.util.Pair;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.EditText;
import android.widget.ListView;

import com.fortysevendeg.swipelistview.SwipeListView;

public class PackingFragment extends BaseTripFragment implements
		View.OnClickListener {
	public static final String TITLE = "";
	private int mCurScreen;
	private static final int[] mListLayout = { R.layout.fragment_packing1,
			R.layout.fragment_packing2, R.layout.fragment_packing3,
			R.layout.fragment_packing4, R.layout.fragment_packing5 };
	private static final String[] mListTitle = { "Packing", "Packing",
			"Custom List", "New List", "Beach" };
	private SwipeListView mSwipeListView;
	private ListView mListView;
	private List<Packing> mListPacking;
	private List<PackingItem> mListPackItem;
	private MainActivity mContext;
	private static Packing sChoosingPremadeTitle = null;

	public PackingFragment(int screen) {
		super(TITLE);
		mCurScreen = screen;
	}

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		mContext = (MainActivity) getActivity();
		View root = inflater.inflate(mListLayout[mCurScreen - 1], container,
				false);
		setTitle(mListTitle[mCurScreen - 1]);
		if (mCurScreen == 5)
			setTitle(sChoosingPremadeTitle.getTitle());
		return root;
	}

	@Override
	protected void initComponents() {
		switch (mCurScreen) {
		case 1:
			break;
		case 2:
			mSwipeListView = (SwipeListView) getView().findViewById(
					R.id.swipe_lv_list);
			SetupSwipeListViewUtils.setup(mSwipeListView, getActivity());
			break;
		case 3:
			mSwipeListView = (SwipeListView) getView().findViewById(
					R.id.swipe_lv_list);
			SetupSwipeListViewUtils.setup(mSwipeListView, getActivity());
			break;
		case 4:
			mListView = (ListView) getView().findViewById(R.id.listView1);
			break;
		case 5:
			mSwipeListView = (SwipeListView) getView().findViewById(
					R.id.swipe_lv_list);
			SetupSwipeListViewUtils.setup(mSwipeListView, getActivity());
			break;
		default:
			break;
		}
	}

	@Override
	protected void addListener() {
		super.addListener();
		switch (mCurScreen) {
		case 1:
			getView().findViewById(R.id.btn1).setOnClickListener(this);
			getView().findViewById(R.id.btn2).setOnClickListener(this);
			break;
		case 2:
			getView().findViewById(R.id.btn1).setOnClickListener(this);
			getView().findViewById(R.id.btn2).setOnClickListener(this);
			break;
		case 3:
			getView().findViewById(R.id.btn1).setOnClickListener(this);
			getView().findViewById(R.id.btn2).setOnClickListener(this);
			changeBtnMenuToBack("");
			break;
		case 4:
			changeBtnMenuToBack("");
			mListView
					.setOnItemClickListener(new AdapterView.OnItemClickListener() {
						@Override
						public void onItemClick(AdapterView<?> parent,
								View view, int position, long id) {
							((ListPreMadeAdapter) mListView.getAdapter())
									.setSelectItem(position);
							sChoosingPremadeTitle = mListPacking.get(position);
							if (sChoosingPremadeTitle.getServerId() > 0)
								((MainActivity) getActivity())
										.changeScreen(Screen.PACKING_5);
						}
					});
			break;
		case 5:
			getView().findViewById(R.id.btn1).setOnClickListener(this);
			getView().findViewById(R.id.btn2).setOnClickListener(this);
			changeBtnMenuToBack("");
			break;

		default:
		}
	}

	@Override
	public void preLoadData() {
		switch (mCurScreen) {
		case 2:
			initPacking();
			break;
		case 3:
			initCustomPacking();
			break;
		case 4:
			initPreMadeList();
			break;
		case 5:
			initPreMadeItem();
			break;
		default:
			break;
		}
	}

	@Override
	public void onClick(View v) {
		MainActivity mother = (MainActivity) getActivity();
		switch (mCurScreen) {
		case 1:
		case 2:
			if (v.getId() == R.id.btn1) {
				mother.changeScreen(Screen.PACKING_3);
			} else if (v.getId() == R.id.btn2) {
				mother.changeScreen(Screen.PACKING_4);
			}
			break;
		case 3:
			if (v.getId() == R.id.btn1) {
				EditText et = ((EditText) getView().findViewById(
						R.id.et_additem));
				String strItem = et.getText().toString();
				et.setText("");
				addItemPacking(strItem);
			} else if (v.getId() == R.id.btn2) {
				if (mListPackItem.size() > 0)
					showSaveDialog();
				else
					mContext.showToast(getString(R.string.toast_invalid_additem));
			}
			break;
		case 4:
			break;
		case 5:
			if (v.getId() == R.id.btn1) {
				showSaveDialog();
			} else if (v.getId() == R.id.btn2) {
				new AddItemDialog(getActivity(), this).show();
			}
			break;
		}
	}

	@SuppressWarnings("rawtypes")
	public void addItemPacking(String strItem) {
		if (strItem.length() > 0 && !StringUtils.isOnlyContainSpace(strItem)) {
			mListPackItem.add(0, new PackingItem(-1, strItem, true));
			((BaseArrayAdapter) mSwipeListView.getAdapter())
					.notifyDataSetChanged();
		} else {
			mContext.showToast(getString(R.string.toast_invalid_additem));
		}
	}

	private void initCustomPacking() {
		mListPackItem = new ArrayList<PackingItem>();
		mSwipeListView.setAdapter(new ListItemAdapter(getActivity(),
				mListPackItem));
	}

	private void initPacking() {
		mListPacking = new PackingTitleTableAdapter(getActivity())
				.getPackingsOfUser(mContext.getUserId());
		if (mListPacking != null) {
			PackingItemTableAdapter packItemTA = new PackingItemTableAdapter(
					mContext);
			for (Packing pack : mListPacking) {
				if (pack.getServerId() == 0)
					pack.setListItem(packItemTA.getItemsOfTitle(pack.getId()));
				else {
					pack.setListItem(packItemTA.getItemsOfTitle(pack
							.getServerId()));
				}
				pack.calculatePercent();
			}
			mSwipeListView.setAdapter(new PackingAdapter(getActivity(),
					mListPacking));
		} else {
			mContext.changeScreen(Screen.PACKING_1);
		}
	}

	private void initPreMadeList() {
		mListPacking = new PremadePackingTitleTableAdapter(mContext)
				.getPremadePackingTitles();
		mListView
				.setAdapter(new ListPreMadeAdapter(getActivity(), mListPacking));
	}

	private void initPreMadeItem() {
		mListPackItem = new PremadePackingItemTableAdapter(mContext)
				.getPremadeItemsOfTitle(sChoosingPremadeTitle.getServerId());
		mSwipeListView.setAdapter(new ListItemAdapter(getActivity(),
				mListPackItem));
	}

	private void showSaveDialog() {
		CustomDialog dialog = new CustomDialog(getActivity(),
				getString(R.string.save_list),
				getString(R.string.save_list_content));
		dialog.getWindow().setBackgroundDrawable(
				new ColorDrawable(android.graphics.Color.TRANSPARENT));
		dialog.setOnClickLeft(new CustomDialog.OnClickLeft() {

			@Override
			public void click() {
				String title = ((EditText) getView().findViewById(
						R.id.EditText1)).getText().toString();
				if (title.length() > 0
						&& !StringUtils.isOnlyContainSpace(title)) {
					Packing packTitle = new Packing(-1, title, mContext
							.getUserId(), 0, ContentProviderDB.FLAG_ADD);
					int listId = new PackingTitleTableAdapter(mContext)
							.addPackingTitle(packTitle);
					for (PackingItem pack : mListPackItem) {
						pack.setListId(listId);
						pack.setServerId(0);
						pack.setFlag(ContentProviderDB.FLAG_ADD);
					}
					new PackingItemTableAdapter(mContext)
							.addListPackingItem(mListPackItem);
					PackingFragment.syncPackingTitle(mContext);
					mContext.changeScreen(Screen.PACKING_2);
				} else {
					mContext.showToast(getString(R.string.toast_invalid_titlepacking));
				}
			}
		});
		dialog.setOnClickRight(new CustomDialog.OnClickRight() {

			@Override
			public void click() {
			}
		});
		dialog.show();
		dialog.setTextBtn(getString(R.string.btn_yes),
				getString(R.string.btn_no));
	}

	// This Variable use to fix bug happen when slow connection, while a row is
	// uploading, user upload that row again which make data is duplicated
	private static List<Integer> sIdsUploading = new LinkedList<Integer>();
	private static List<Integer> sIdsItemUploading = new LinkedList<Integer>();

	public static void clearUploading(
			List<Pair<Integer, Integer>> listIdUploaded) {
		for (Pair<Integer, Integer> pair : listIdUploaded)
			sIdsUploading.remove(pair.first);
	}

	public static void clearItemUploading(
			List<Pair<Integer, Integer>> itemIdsUploaded) {
		for (Pair<Integer, Integer> pair : itemIdsUploaded)
			sIdsItemUploading.remove(pair.first);
	}

	public static void syncPackingTitle(MainActivity context) {
		int packTitleVer = new VersionTableAdapter(context)
				.getVersionTableofUser(context.getUserId(),
						ContentProviderDB.COL_VERSION_PACKING);
		List<Packing> listPacking = new PackingTitleTableAdapter(context)
				.getPackingsNeedUpload();
		if (listPacking != null)
			for (int i = 0; i < listPacking.size(); i++) {
				int id = listPacking.get(i).getId();
				boolean isRemove = false;
				for (int uploading : sIdsUploading) {
					if (uploading == id)
						isRemove = true;
				}
				if (isRemove) {
					listPacking.remove(i);
					i--;
				} else
					sIdsUploading.add(id);
			}
		new SyncPackingWS(context).fetchData(packTitleVer, JSONParseUtils
				.convertPackingTitlesToJSONArray(listPacking,
						context.getTripId()), context.getUserId());
	}

	public static void syncPackingItem(MainActivity context) {
		int packItemVer = new VersionTableAdapter(context)
				.getVersionTableofUser(context.getUserId(),
						ContentProviderDB.COL_VERSION_PACKINGITEM);
		List<PackingItem> listPackingItem = new PackingItemTableAdapter(context)
				.getPackingsNeedUpload();
		if (listPackingItem != null)
			for (int i = 0; i < listPackingItem.size(); i++) {
				int id = listPackingItem.get(i).getId();
				boolean isRemove = false;
				for (int uploading : sIdsItemUploading) {
					if (uploading == id)
						isRemove = true;
				}
				if (isRemove) {
					listPackingItem.remove(i);
					i--;
				} else
					sIdsItemUploading.add(id);
			}
		new SyncPackingItemWS(context).fetchData(packItemVer,
				JSONParseUtils.convertPackingItemToJSONArray(listPackingItem),
				context.getUserId());
	}
}
