package sdc.ui.travelapp;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import sdc.application.TravelApplication;
import sdc.application.TravelPrefs;
import sdc.data.Category;
import sdc.data.Expense;
import sdc.data.Note;
import sdc.data.Packing;
import sdc.data.PackingItem;
import sdc.data.Trip;
import sdc.data.User;
import sdc.data.database.ContentProviderDB;
import sdc.data.database.adapter.CategoryTableAdapter;
import sdc.data.database.adapter.ExpenseTableAdapter;
import sdc.data.database.adapter.NoteTableAdapter;
import sdc.data.database.adapter.PackingItemTableAdapter;
import sdc.data.database.adapter.PackingTitleTableAdapter;
import sdc.data.database.adapter.PhotoTableAdapter;
import sdc.data.database.adapter.PremadePackingItemTableAdapter;
import sdc.data.database.adapter.PremadePackingTitleTableAdapter;
import sdc.data.database.adapter.TripTableAdapter;
import sdc.data.database.adapter.UserTableAdapter;
import sdc.data.database.adapter.UsersInGroupTableAdapter;
import sdc.data.database.adapter.VersionTableAdapter;
import sdc.net.listeners.IWebServiceListener;
import sdc.net.utils.Base64;
import sdc.net.webservice.AddTripWS;
import sdc.net.webservice.BaseSyncWS;
import sdc.net.webservice.BaseWS;
import sdc.net.webservice.GetPremadeItemWS;
import sdc.net.webservice.GetPremadePackingWS;
import sdc.net.webservice.GetTripWS;
import sdc.net.webservice.GetUserDataWS;
import sdc.net.webservice.GetVersionWS;
import sdc.net.webservice.LoginWS;
import sdc.net.webservice.RemoveGcmWS;
import sdc.net.webservice.SyncPhotosWS;
import sdc.travelapp.GCMIntentService;
import sdc.travelapp.R;
import sdc.ui.adapter.NavigationAdapter;
import sdc.ui.customview.CustomDialog;
import sdc.ui.fragment.AboutFragment;
import sdc.ui.fragment.AccountFragment;
import sdc.ui.fragment.AddExpensesFragment;
import sdc.ui.fragment.AddPhotoFragment;
import sdc.ui.fragment.AddTripFragment;
import sdc.ui.fragment.AlertFragment;
import sdc.ui.fragment.BaseFragment;
import sdc.ui.fragment.CreateAccFragment;
import sdc.ui.fragment.CreateSlideShowFragment;
import sdc.ui.fragment.ExpensesFragment;
import sdc.ui.fragment.GroupFragment;
import sdc.ui.fragment.HomeFragment;
import sdc.ui.fragment.HomeTripFragment;
import sdc.ui.fragment.InviteFragment;
import sdc.ui.fragment.LoginFragment;
import sdc.ui.fragment.NotesFragment;
import sdc.ui.fragment.PackingFragment;
import sdc.ui.fragment.ReceiptsFragment;
import sdc.ui.fragment.ReviewSlideShowFragment;
import sdc.ui.fragment.SendReceiptFragment;
import sdc.ui.fragment.SlideShowFragment;
import sdc.ui.fragment.TakePhotoFragment;
import android.annotation.SuppressLint;
import android.app.ProgressDialog;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.content.pm.Signature;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.os.CountDownTimer;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;
import android.support.v4.widget.DrawerLayout;
import android.support.v4.widget.DrawerLayout.DrawerListener;
import android.util.Log;
import android.util.Pair;
import android.view.Gravity;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.inputmethod.InputMethodManager;
import android.widget.AdapterView;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;

import com.google.android.gcm.GCMRegistrar;
import com.nikmesoft.nmsharekit.utils.NMSKFacebookSession;

public class MainActivity extends FragmentActivity implements
		IWebServiceListener {
	private DrawerLayout mDrawerLayout;
	private boolean isNaviOpen = false;
	private ListView mMenuList;
	private TextView tvLogout;
	private boolean isReadyExit = false;
	private CountDownTimer mCountDown;
	private int mReplacePosition = -1;
	private boolean isReset = false;
	private boolean isPaused = false;

	public static String FILTER_ACTION_END_TRIP = "sdc.travelapp.END_TRIP";
	private BroadcastReceiver endtripBroadcastReceiver = new BroadcastReceiver() {

		@Override
		public void onReceive(Context context, Intent intent) {
			// if (mTripId != 0 && mTripId == intent.getIntExtra("trip_id", 0))
			// {
			String msg = intent.getStringExtra("msg");
			Toast.makeText(MainActivity.this, msg, Toast.LENGTH_LONG).show();

			onEndTrip();
			// }
		}
	};

	public enum Screen {
		HOME, ACCOUNT, ADD_PHOTO, TAKE_PHOTO, NOTE, EXPENSES, PACKING_1, ALERT, SLIDESHOW, GROUP, RECEIPTS, ADD_TRIP, INVITE, ADD_EXPENSES, ABOUT, CREATE_ACC, LOGIN, HOME_TRIP, PACKING_2, PACKING_3, PACKING_4, PACKING_5, CREATE_SLIDESHOW, REVIEW_SLIDESHOW
	}

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);

		try {
			PackageInfo info = getPackageManager().getPackageInfo(
					getPackageName(), PackageManager.GET_SIGNATURES);
			for (Signature signature : info.signatures) {
				MessageDigest md = MessageDigest.getInstance("SHA");
				md.update(signature.toByteArray());
				Log.i("PXR", Base64.encodeBytes(md.digest()));
			}
		} catch (NameNotFoundException e) {
		} catch (NoSuchAlgorithmException e) {
		}
		createNavigation();
		createLogout();
		if (getIntent().getBooleanExtra("is_group", false)) {
			this.changeFragmentBaseOnMenu(9);
		} else {
			/*
			 * ((TravelApplication) this.getApplication())
			 * .setTripAdded(((Integer) TravelPrefs.getData( MainActivity.this,
			 * TravelPrefs.PREF_TRIP_ID)) != 0); if (((Integer)
			 * TravelPrefs.getData(MainActivity.this, TravelPrefs.PREF_USER_ID))
			 * != 0) { String mail = (String) TravelPrefs.getData(this,
			 * TravelPrefs.PREF_USER_MAIL); String pass = (String)
			 * TravelPrefs.getData(this, TravelPrefs.PREF_USER_PASS); new
			 * LoginWS(this, this).fetchData(mail, pass); }
			 */
			this.move2FirstScreen();
		}
		createCountDownTimer();
		registerReceiver(endtripBroadcastReceiver, new IntentFilter(
				FILTER_ACTION_END_TRIP));
	}

	@Override
	protected void onDestroy() {
		unregisterReceiver(endtripBroadcastReceiver);
		super.onDestroy();
	}

	private void createNavigation() {
		mDrawerLayout = (DrawerLayout) findViewById(R.id.drawer_layout);
		mDrawerLayout.setScrimColor(getResources().getColor(
				android.R.color.transparent));
		mDrawerLayout.setDrawerListener(new DrawerListener() {
			@Override
			public void onDrawerStateChanged(int arg0) {
			}

			@Override
			public void onDrawerSlide(View arg0, float arg1) {
			}

			@Override
			public void onDrawerOpened(View arg0) {
				isNaviOpen = true;
				hideSoftKeyBoard();
			}

			@Override
			public void onDrawerClosed(View arg0) {
				isNaviOpen = false;
				if (mReplacePosition != -1) {
					changeFragmentBaseOnMenu(mReplacePosition);
					mReplacePosition = -1;
				}

			}
		});
		mMenuList = (ListView) findViewById(R.id.left_drawer);
		mMenuList.setAdapter(new NavigationAdapter(getApplicationContext()));
		mMenuList.setOnItemClickListener(new AdapterView.OnItemClickListener() {
			@Override
			public void onItemClick(AdapterView<?> parent, View view,
					int position, long id) {
				((NavigationAdapter) mMenuList.getAdapter())
						.setSelectedPosition(position);
				openOrCloseNavi();
				mReplacePosition = position;
			}
		});
	}

	/**
	 * @param fragment
	 *            fragment to replace in main screen
	 * @param isAddBackStack
	 *            whether fragment add stack to comeback or not
	 */
	public void replaceContent(BaseFragment fragment, boolean isAddBackStack) {
		hideSoftKeyBoard();
		if (getCurFragment() != null
				&& getCurFragment().getClass().equals(fragment.getClass())
				&& !(fragment instanceof PackingFragment))
			return;
		FragmentManager manager = getSupportFragmentManager();
		FragmentTransaction transaction = manager.beginTransaction();
		transaction.replace(R.id.content_frame, fragment);
		if (isAddBackStack) {
			transaction.addToBackStack(null);
		} else if (manager.getBackStackEntryCount() > 0) {
			manager.popBackStack(null, FragmentManager.POP_BACK_STACK_INCLUSIVE);
		}
		transaction.commit();
	}

	public void replaceContent(BaseFragment fragment, boolean isAddBackStack,
			int inAnim, int outAnim) {
		hideSoftKeyBoard();
		if (getCurFragment() != null
				&& getCurFragment().getClass().equals(fragment.getClass())
				&& !(fragment instanceof PackingFragment))
			return;
		FragmentManager manager = getSupportFragmentManager();
		FragmentTransaction transaction = manager.beginTransaction();
		transaction.setCustomAnimations(inAnim, outAnim);
		transaction.replace(R.id.content_frame, fragment);
		if (isAddBackStack) {
			transaction.addToBackStack(null);
		} else if (manager.getBackStackEntryCount() > 0) {
			manager.popBackStack(null, FragmentManager.POP_BACK_STACK_INCLUSIVE);
		}
		transaction.commit();
	}

	public void changeScreen(Screen screen) {
		try {
			mDrawerLayout.setDrawerLockMode(DrawerLayout.LOCK_MODE_UNLOCKED);
			changeSelectedPositionOnNavigationMenu(screen);
			switch (screen) {
			case HOME:
				replaceContent(new HomeFragment(), false);
				break;
			case ACCOUNT:
				replaceContent(new AccountFragment(), false);
				break;
			case ADD_PHOTO:
				replaceContent(new AddPhotoFragment(), false);
				break;
			case TAKE_PHOTO:
				replaceContent(new TakePhotoFragment(), false);
				break;
			case NOTE:
				replaceContent(new NotesFragment(), false);
				break;
			case EXPENSES:
				replaceContent(new ExpensesFragment(), false);
				break;
			case PACKING_1:
				replaceContent(new PackingFragment(1), false);
				break;
			case ALERT:
				replaceContent(new AlertFragment(), false);
				break;
			case SLIDESHOW:
				replaceContent(new SlideShowFragment(), false);
				break;
			case GROUP:
				replaceContent(new GroupFragment(), false);
				break;
			case RECEIPTS:
				replaceContent(new ReceiptsFragment(), false);
				break;
			case ADD_TRIP:
				replaceContent(new AddTripFragment(), false);
				break;
			case INVITE:
				replaceContent(new InviteFragment(), true);
				break;
			case ADD_EXPENSES:
				replaceContent(new AddExpensesFragment(), true);
				break;
			case ABOUT:
				replaceContent(new AboutFragment(), true);
				mDrawerLayout
						.setDrawerLockMode(DrawerLayout.LOCK_MODE_LOCKED_CLOSED);
				break;
			case CREATE_ACC:
				replaceContent(new CreateAccFragment(), false);
				mDrawerLayout
						.setDrawerLockMode(DrawerLayout.LOCK_MODE_LOCKED_CLOSED);
				break;
			case LOGIN:
				replaceContent(new LoginFragment(), false);
				mDrawerLayout
						.setDrawerLockMode(DrawerLayout.LOCK_MODE_LOCKED_CLOSED);
				break;
			case HOME_TRIP:
				if (checkTripAdded())
					replaceContent(new HomeTripFragment(), false);
				break;
			case PACKING_2:
				replaceContent(new PackingFragment(2), false);
				break;
			case PACKING_3:
				replaceContent(new PackingFragment(3), true);
				break;
			case PACKING_4:
				replaceContent(new PackingFragment(4), true);
				break;
			case PACKING_5:
				replaceContent(new PackingFragment(5), true);
				break;
			case CREATE_SLIDESHOW:
				replaceContent(new CreateSlideShowFragment(), true);
				break;
			case REVIEW_SLIDESHOW:
				replaceContent(new ReviewSlideShowFragment(), true);
				break;
			default:

			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public void changeScreen(Screen screen, int inAnim, int outAnim) {
		try {
			mDrawerLayout.setDrawerLockMode(DrawerLayout.LOCK_MODE_UNLOCKED);
			changeSelectedPositionOnNavigationMenu(screen);
			switch (screen) {
			case HOME:
				replaceContent(new HomeFragment(), false, inAnim, outAnim);
				break;
			case ACCOUNT:
				replaceContent(new AccountFragment(), false, inAnim, outAnim);
				break;
			case ADD_PHOTO:
				replaceContent(new AddPhotoFragment(), false, inAnim, outAnim);
				break;
			case TAKE_PHOTO:
				replaceContent(new TakePhotoFragment(), false, inAnim, outAnim);
				break;
			case NOTE:
				replaceContent(new NotesFragment(), false, inAnim, outAnim);
				break;
			case EXPENSES:
				replaceContent(new ExpensesFragment(), false, inAnim, outAnim);
				break;
			case PACKING_1:
				replaceContent(new PackingFragment(1), false, inAnim, outAnim);
				break;
			case ALERT:
				replaceContent(new AlertFragment(), false, inAnim, outAnim);
				break;
			case SLIDESHOW:
				replaceContent(new SlideShowFragment(), false, inAnim, outAnim);
				break;
			case GROUP:
				replaceContent(new GroupFragment(), false, inAnim, outAnim);
				break;
			case RECEIPTS:
				replaceContent(new ReceiptsFragment(), false, inAnim, outAnim);
				break;
			case ADD_TRIP:
				replaceContent(new AddTripFragment(), false, inAnim, outAnim);
				break;
			case INVITE:
				replaceContent(new InviteFragment(), true, inAnim, outAnim);
				break;
			case ADD_EXPENSES:
				replaceContent(new AddExpensesFragment(), true, inAnim, outAnim);
				break;
			case ABOUT:
				replaceContent(new AboutFragment(), true, inAnim, outAnim);
				mDrawerLayout
						.setDrawerLockMode(DrawerLayout.LOCK_MODE_LOCKED_CLOSED);
				break;
			case CREATE_ACC:
				replaceContent(new CreateAccFragment(), false, inAnim, outAnim);
				mDrawerLayout
						.setDrawerLockMode(DrawerLayout.LOCK_MODE_LOCKED_CLOSED);
				break;
			case LOGIN:
				replaceContent(new LoginFragment(), false, inAnim, outAnim);
				mDrawerLayout
						.setDrawerLockMode(DrawerLayout.LOCK_MODE_LOCKED_CLOSED);
				break;
			case HOME_TRIP:
				if (checkTripAdded())
					replaceContent(new HomeTripFragment(), false, inAnim,
							outAnim);
				break;
			case PACKING_2:
				replaceContent(new PackingFragment(2), false, inAnim, outAnim);
				break;
			case PACKING_3:
				replaceContent(new PackingFragment(3), true, inAnim, outAnim);
				break;
			case PACKING_4:
				replaceContent(new PackingFragment(4), true, inAnim, outAnim);
				break;
			case PACKING_5:
				replaceContent(new PackingFragment(5), true, inAnim, outAnim);
				break;
			case CREATE_SLIDESHOW:
				replaceContent(new CreateSlideShowFragment(), true, inAnim,
						outAnim);
				break;
			case REVIEW_SLIDESHOW:
				replaceContent(new ReviewSlideShowFragment(), true, inAnim,
						outAnim);
				break;
			default:

			}
		} catch (Exception e) {

		}
	}

	public void showSendReceiptFragment(String email, boolean sendToOwner) {
		SendReceiptFragment fragment = new SendReceiptFragment();
		fragment.setEmail(email);
		fragment.setSendToOwner(sendToOwner);
		replaceContent(fragment, true);
	}

	private void changeFragmentBaseOnMenu(int pos) {
		switch (pos) {
		case 0:
			move2FirstScreen();
			break;
		case 1:
			changeScreen(Screen.ACCOUNT);
			break;
		case 2:
			if (checkTripAdded())
				changeScreen(Screen.ADD_PHOTO);
			break;
		case 3:
			if (checkTripAdded())
				changeScreen(Screen.TAKE_PHOTO);
			break;
		case 4:
			if (checkTripAdded())
				changeScreen(Screen.NOTE);
			break;
		case 5:
			if (checkTripAdded())
				changeScreen(Screen.EXPENSES);
			break;
		case 6:
			if (checkTripAdded())
				changeScreen(Screen.PACKING_2);
			break;
		case 7:
			if (checkTripAdded())
				changeScreen(Screen.ALERT);
			break;
		case 8:
			if (checkTripAdded())
				changeScreen(Screen.SLIDESHOW);
			break;
		case 9:
			if (checkTripAdded())
				changeScreen(Screen.GROUP);
			break;
		case 10:
			if (checkTripAdded())
				changeScreen(Screen.RECEIPTS);
			break;
		default:
			break;
		}
	}

	public void changeSelectedPositionOnNavigationMenu(Screen screen) {
		int selectedPos = -1;
		switch (screen) {
		case HOME:
			selectedPos = 0;
			break;
		case ACCOUNT:
			selectedPos = 1;
			break;
		case ADD_PHOTO:
			selectedPos = 2;
			break;
		case TAKE_PHOTO:
			selectedPos = 3;
			break;
		case NOTE:
			selectedPos = 4;
			break;
		case EXPENSES:
			selectedPos = 5;
			break;
		case PACKING_1:
			selectedPos = 6;
			break;
		case ALERT:
			selectedPos = 7;
			break;
		case SLIDESHOW:
			selectedPos = 8;
			break;
		case GROUP:
			selectedPos = 9;
			break;
		case RECEIPTS:
			selectedPos = 10;
			break;
		case ADD_TRIP:
			selectedPos = 0;
			break;
		case INVITE:
			selectedPos = 9;
			break;
		case ADD_EXPENSES:
			selectedPos = 5;
			break;
		case ABOUT:
			selectedPos = 0;
			break;
		case CREATE_ACC:
			selectedPos = 0;
			break;
		case LOGIN:
			selectedPos = 0;
			break;
		case HOME_TRIP:
			selectedPos = 0;
			break;
		case PACKING_2:
			selectedPos = 6;
			break;
		case PACKING_3:
			selectedPos = 6;
			break;
		case PACKING_4:
			selectedPos = 6;
			break;
		case PACKING_5:
			selectedPos = 6;
			break;
		case CREATE_SLIDESHOW:
			selectedPos = 8;
			break;
		case REVIEW_SLIDESHOW:
			selectedPos = 8;
			break;
		default:
		}
		((NavigationAdapter) mMenuList.getAdapter())
				.setSelectedPosition(selectedPos);
	}

	/*
	 * If NavigationDrawer is close, it will open and contrary
	 */
	@SuppressLint("RtlHardcoded")
	public void openOrCloseNavi() {
		if (isNaviOpen) {
			mDrawerLayout.closeDrawers();
		} else {
			mDrawerLayout.openDrawer(Gravity.LEFT);
		}
	}

	/**
	 * @return true if tripped, else return false and move to addtrip screen
	 */
	private boolean checkTripAdded() {
		TravelApplication app = (TravelApplication) this.getApplication();
		if (!app.isTripAdded()) {
			this.changeScreen(Screen.ADD_TRIP);
			((NavigationAdapter) mMenuList.getAdapter()).setSelectedPosition(0);
			Toast.makeText(this, getString(R.string.not_addtrip_yet),
					Toast.LENGTH_SHORT).show();
			return false;
		}
		return true;
	}

	private void move2FirstScreen() {
		((NavigationAdapter) mMenuList.getAdapter()).setSelectedPosition(0);
		TravelApplication app = (TravelApplication) getApplication();
		if (((Integer) TravelPrefs.getData(MainActivity.this,
				TravelPrefs.PREF_USER_ID)) <= 0)
			changeScreen(Screen.LOGIN);
		else if (!app.isTripAdded()
				|| ((Integer) TravelPrefs.getData(this,
						TravelPrefs.PREF_TRIP_ID)) <= 0)
			changeScreen(Screen.HOME);
		else
			changeScreen(Screen.HOME_TRIP);
	}

	private void createLogout() {
		tvLogout = (TextView) findViewById(R.id.tvLogout);

		tvLogout.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				tvLogout.setTextColor(getResources().getColor(
						R.color.text_green_color));
				mDrawerLayout.closeDrawers();
				showLogoutDialog();
			}
		});
	}

	protected void showLogoutDialog() {
		CustomDialog dialog = new CustomDialog(this,
				getString(R.string.logout_title),
				getString(R.string.logout_content));
		dialog.getWindow().setBackgroundDrawable(
				new ColorDrawable(android.graphics.Color.TRANSPARENT));
		dialog.setOnClickLeft(new CustomDialog.OnClickLeft() {

			@Override
			public void click() {
				// TravelPrefs.putData(MainActivity.this,
				// TravelPrefs.PREF_USER_PASS, "");
				new RemoveGcmWS(MainActivity.this).fetchData(GCMRegistrar
						.getRegistrationId(MainActivity.this));
				runOnUiThread(new Runnable() {

					@Override
					public void run() {
						// finish();
						// Intent intent = new Intent(getApplicationContext(),
						// MainActivity.class);
						// intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP
						// | Intent.FLAG_ACTIVITY_NEW_TASK);
						// startActivity(intent);
						// TravelPrefs.logOut(MainActivity.this);
						new VersionTableAdapter(MainActivity.this)
								.setVersionTableOfUser(
										ContentProviderDB.COL_VERSION_EXPENSE,
										0, mUserId);
						new VersionTableAdapter(MainActivity.this)
								.setVersionTableOfUser(
										ContentProviderDB.COL_VERSION_CATE, 0,
										mUserId);
						TravelPrefs.logOut(MainActivity.this);
						((NavigationAdapter) mMenuList.getAdapter())
								.setSelectedPosition(0);

						tvLogout.setTextColor(getResources().getColor(
								R.color.text_white_color));
						((TravelApplication) getApplication())
								.setTripLogin(false);
						((TravelApplication) getApplication())
								.setTripAdded(false);

						changeScreen(Screen.LOGIN);

					}
				});

				// Intent intent = new Intent(getApplicationContext(),
				// MainActivity.class);
				// intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP
				// | Intent.FLAG_ACTIVITY_NEW_TASK
				// | Intent.FLAG_ACTIVITY_CLEAR_TASK);
				// startActivity(intent);

			}
		});
		dialog.setOnClickRight(new CustomDialog.OnClickRight() {

			@Override
			public void click() {
				tvLogout.setTextColor(getResources().getColor(
						R.color.text_white_color));
			}
		});
		dialog.show();
		dialog.setTextBtn(getString(R.string.btn_yes),
				getString(R.string.btn_no));
	}

	@Override
	public void onBackPressed() {
		hideSoftKeyBoard();
		if (isNaviOpen) {
			mDrawerLayout.closeDrawers();
		} else {
			if (getSupportFragmentManager().getBackStackEntryCount() > 0) {
				super.onBackPressed();
				return;
			}
			BaseFragment fragment = getCurFragment();
			if (!(fragment instanceof HomeFragment
					|| fragment instanceof HomeTripFragment || fragment instanceof LoginFragment)) {
				move2FirstScreen();
			} else {
				if (!isReadyExit) {
					isReadyExit = true;
					Toast.makeText(this, "Press again to exit",
							Toast.LENGTH_SHORT).show();
					mCountDown.start();
				} else
					finish();
			}
		}
	}

	private void createCountDownTimer() {
		mCountDown = new CountDownTimer(2000, 2000) {

			@Override
			public void onTick(long millisUntilFinished) {
			}

			@Override
			public void onFinish() {
				isReadyExit = false;
			}
		};
	}

	public BaseFragment getCurFragment() {
		return (BaseFragment) getSupportFragmentManager().findFragmentById(
				R.id.content_frame);
	}

	public void reloadCurFragment() {
		BaseFragment fragment = getCurFragment();
		if (fragment != null)
			fragment.preLoadData();
	}

	public void hideSoftKeyBoard() {
		InputMethodManager inputMethodManager = (InputMethodManager) MainActivity.this
				.getSystemService(FragmentActivity.INPUT_METHOD_SERVICE);
		try {
			inputMethodManager.hideSoftInputFromWindow(MainActivity.this
					.getCurrentFocus().getWindowToken(), 0);
		} catch (Exception e) {
		}
	}

	/*
	 * =========================================================================
	 * Commit and update all data //TODO webservice comunicator
	 * =========================================================================
	 */
	private ProgressDialog mProgressDialog;
	private int mTripId;
	private int mUserId;

	// private void checkForCrashes() {
	// CrashManager.register(this, "9");
	// }

	@Override
	protected void onResume() {
		super.onResume();
		// checkForCrashes();
		getFrequentPrefs();
		isPaused = false;
		if (isReset) {
			move2FirstScreen();
			isReset = false;
		}
	}

	public void getFrequentPrefs() {
		mTripId = (Integer) TravelPrefs.getData(this, TravelPrefs.PREF_TRIP_ID);
		mUserId = (Integer) TravelPrefs.getData(this, TravelPrefs.PREF_USER_ID);
	}

	public void showToast(String info) {
		Toast.makeText(this, info, Toast.LENGTH_SHORT).show();
	}

	public void showProgressDialog(String title, String message,
			DialogInterface.OnCancelListener listener) {
		mProgressDialog = new ProgressDialog(this);
		mProgressDialog.setCancelable(true);
		mProgressDialog.setOnCancelListener(listener);
		mProgressDialog.setCanceledOnTouchOutside(false);
		mProgressDialog.setTitle(title);
		mProgressDialog.setIndeterminate(true);
		mProgressDialog.setMessage(message);
		mProgressDialog.show();
	}

	public void dismissProgressDialog() {
		if (mProgressDialog != null)
			mProgressDialog.dismiss();
	}

	public static int sCountRunningWS = 0;

	@Override
	public void onConnectionOpen(int type) {
		sCountRunningWS++;
	}

	@Override
	public void onConnectionError(int type, String fault) {
		sCountRunningWS = sCountRunningWS == 0 ? 0 : sCountRunningWS - 1;
		if (mProgressDialog != null && sCountRunningWS == 0)
			mProgressDialog.dismiss();
		switch (type) {
		case BaseWS.LOGIN:
			showToast(getString(R.string.toast_problem_network));
			break;
		case BaseWS.CREATE_USER:
			showToast(getString(R.string.toast_problem_network));
			break;
		case BaseWS.EDIT_ACC:
			showToast(getString(R.string.toast_problem_network));
			break;
		case BaseWS.SYNC_NOTE:
			showToast(getString(R.string.toast_problem_network));
			break;
		case BaseWS.SYNC_EXPENSE:
			break;
		case BaseWS.GET_PREMADE_LIST:
			break;
		case BaseWS.GET_PREMADE_ITEM:
			break;
		case BaseWS.SYNC_PACKING_LIST:
			break;
		case BaseWS.SYNC_PACKING_ITEM:
			break;
		case BaseWS.SYNC_GROUP:
			break;
		case BaseWS.SYNC_PHOTO:
			break;
		case BaseWS.ADD_TRIP:
			showToast(getString(R.string.toast_problem_network));
			break;
		case BaseWS.GET_TRIP:
			showToast(getString(R.string.toast_problem_network));
			break;
		case BaseWS.END_TRIP:
			showToast(getString(R.string.toast_problem_network));
			break;
		case BaseWS.GET_VERSION:
			showToast(getString(R.string.toast_problem_network));
			break;
		case BaseWS.SEND_MAIL_INVITE:
			showToast(getString(R.string.toast_problem_network));
			break;
		case BaseWS.SEND_RECEIPT:
			showToast(getString(R.string.toast_problem_network));
			break;
		default:
			showToast(getString(R.string.toast_problem_network));
			break;
		}
	}

	@SuppressWarnings({ "rawtypes", "unchecked" })
	@Override
	public void onConnectionDone(BaseWS wsControl, int type, String result) {
		sCountRunningWS = sCountRunningWS == 0 ? 0 : sCountRunningWS - 1;
		if (mProgressDialog != null && sCountRunningWS == 0)
			mProgressDialog.dismiss();
		switch (type) {
		case BaseWS.LOGIN:
			User loginInfo = (User) wsControl.parseData(result);
			if (loginInfo == null) {
				String errorMess = LoginWS.parseFaultMessage(result);
				showToast(errorMess.length() > 0 ? errorMess
						: getString(R.string.toast_uncaught_prob));
			} else {
				TravelPrefs.putLoginData(this, loginInfo);
				getFrequentPrefs();
				((TravelApplication) this.getApplication()).setTripLogin(true);
				if (loginInfo.getTripId() != -1)
					((TravelApplication) this.getApplication())
							.setTripAdded(true);
				// if (getIntent().getBooleanExtra("is_group", false)) {
				// this.changeFragmentBaseOnMenu(9);
				// } else {
				// this.move2FirstScreen();
				// }
				Fragment fragment = getSupportFragmentManager()
						.findFragmentById(R.id.content_frame);
				if (fragment == null || fragment instanceof LoginFragment
						|| fragment instanceof HomeFragment
						|| fragment instanceof HomeTripFragment) {
					move2FirstScreen();
				}

			}
			break;
		case BaseWS.CREATE_USER:
			break;
		case BaseWS.EDIT_ACC:
			break;
		case BaseWS.SYNC_NOTE:
			if (wsControl instanceof BaseSyncWS) {
				// parse 3 module data from server
				List<Note> updateRows = (List<Note>) wsControl
						.parseData(result);
				List<Pair<Integer, Integer>> updateId = ((BaseSyncWS) wsControl)
						.parseNewServerId(result);
				int newNoteVersion = ((BaseSyncWS) wsControl)
						.parseNewVersion(result);
				// handle each of module
				if (updateRows != null && updateId != null
						&& newNoteVersion != -1) {
					new NoteTableAdapter(this).doneUpdatingFromServer(updateId);
					NotesFragment.clearUploading(updateId);
					new VersionTableAdapter(this).setVersionTableOfUser(
							ContentProviderDB.COL_VERSION_NOTE, newNoteVersion,
							mUserId);
					new NoteTableAdapter(this).handleDataFromServer(updateRows);
					if (getCurFragment() instanceof NotesFragment)
						this.reloadCurFragment();
				} else {
					showToast(((BaseSyncWS) wsControl)
							.parseFaultMessage(result));
				}
				Fragment currentFragment = getSupportFragmentManager()
						.findFragmentById(R.id.content_frame);
				if (currentFragment instanceof NotesFragment) {
					((NotesFragment) currentFragment).preLoadData();
				}

			}
			break;
		case BaseWS.SYNC_EXPENSE:
			if (wsControl instanceof BaseSyncWS) {
				// parse 3 module data from server
				List<Expense> updateRows = (List<Expense>) wsControl
						.parseData(result);
				List<Pair<Integer, Integer>> updateId = ((BaseSyncWS) wsControl)
						.parseNewServerId(result);
				int newExpenseVersion = ((BaseSyncWS) wsControl)
						.parseNewVersion(result);
				// handle each of module
				if (updateRows != null && updateId != null
						&& newExpenseVersion != -1) {
					ExpenseTableAdapter tableAdapter = new ExpenseTableAdapter(
							this);

					tableAdapter.doneUpdatingFromServer(updateId);
					ExpensesFragment.clearUploading(updateId);
					new VersionTableAdapter(this).setVersionTableOfUser(
							ContentProviderDB.COL_VERSION_EXPENSE,
							newExpenseVersion, mUserId);
					tableAdapter.handleDataFromServer(updateRows);
					Fragment currentFragment = getSupportFragmentManager()
							.findFragmentById(R.id.content_frame);
					if (currentFragment instanceof HomeTripFragment) {
						((HomeTripFragment) currentFragment).updateExpensive();
					}
					// this.reloadCurFragment();
				} else {
					showToast(((BaseSyncWS) wsControl)
							.parseFaultMessage(result));
				}
			}
			break;
		case BaseWS.SYNC_CATEGORIES:
			if (wsControl instanceof BaseSyncWS) {
				// parse 3 module data from server
				List<Category> updateRows = (List<Category>) wsControl
						.parseData(result);
				List<Pair<Integer, Integer>> updateId = ((BaseSyncWS) wsControl)
						.parseNewServerId(result);
				int newVersion = ((BaseSyncWS) wsControl)
						.parseNewVersion(result);
				// handle each of module
				if (updateRows != null && updateId != null && newVersion != -1) {
					new CategoryTableAdapter(this)
							.doneUpdatingFromServer(updateId);
					new VersionTableAdapter(this).setVersionTableOfUser(
							ContentProviderDB.COL_VERSION_CATE, newVersion,
							mUserId);
					new CategoryTableAdapter(this).handleDataFromServer(
							updateRows, mUserId);
					ExpensesFragment.syncExpenseData(this);
					// this.reloadCurFragment();
				} else {
					showToast(((BaseSyncWS) wsControl)
							.parseFaultMessage(result));
				}
			}
			break;
		case BaseWS.GET_PREMADE_LIST:
			List<Packing> premadeList = (List<Packing>) wsControl
					.parseData(result);
			if (premadeList != null) {
				new PremadePackingTitleTableAdapter(this)
						.addListPremadeTitle(premadeList);
				if (getCurFragment() instanceof PackingFragment)
					this.reloadCurFragment();
			} else {
				showToast(((BaseSyncWS) wsControl).parseFaultMessage(result));
			}
			break;
		case BaseWS.GET_PREMADE_ITEM:
			List<PackingItem> premadeItem = (List<PackingItem>) wsControl
					.parseData(result);
			if (premadeItem != null) {
				new PremadePackingItemTableAdapter(this)
						.addListPremadeItem(premadeItem);
				if (getCurFragment() instanceof PackingFragment)
					this.reloadCurFragment();
			} else {
				showToast(((BaseSyncWS) wsControl).parseFaultMessage(result));
			}
			break;
		case BaseWS.SYNC_PACKING_LIST:
			if (wsControl instanceof BaseSyncWS) {
				// parse 3 module data from server
				List<Packing> updateRows = (List<Packing>) wsControl
						.parseData(result);
				List<Pair<Integer, Integer>> updateId = ((BaseSyncWS) wsControl)
						.parseNewServerId(result);
				int newPackListVersion = ((BaseSyncWS) wsControl)
						.parseNewVersion(result);
				// handle each of module
				if (updateRows != null && updateId != null
						&& newPackListVersion != -1) {
					new PackingTitleTableAdapter(this)
							.doneUpdatingFromServer(updateId);
					PackingFragment.clearUploading(updateId);
					new VersionTableAdapter(this).setVersionTableOfUser(
							ContentProviderDB.COL_VERSION_PACKING,
							newPackListVersion, mUserId);
					new PackingTitleTableAdapter(this)
							.handleDataFromServer(updateRows);
					if (getCurFragment() instanceof PackingFragment)
						this.reloadCurFragment();
				} else {
					showToast(((BaseSyncWS) wsControl)
							.parseFaultMessage(result));
				}
			}
			break;
		case BaseWS.SYNC_PACKING_ITEM:
			if (wsControl instanceof BaseSyncWS) {
				// parse 3 module data from server
				List<PackingItem> updateRows = (List<PackingItem>) wsControl
						.parseData(result);
				List<Pair<Integer, Integer>> updateId = ((BaseSyncWS) wsControl)
						.parseNewServerId(result);
				int newPackItemVersion = ((BaseSyncWS) wsControl)
						.parseNewVersion(result);
				// handle each of module
				if (updateRows != null && updateId != null
						&& newPackItemVersion != -1) {
					new PackingItemTableAdapter(this)
							.doneUpdatingFromServer(updateId);
					PackingFragment.clearItemUploading(updateId);
					new VersionTableAdapter(this).setVersionTableOfUser(
							ContentProviderDB.COL_VERSION_PACKINGITEM,
							newPackItemVersion, mUserId);
					new PackingItemTableAdapter(this)
							.handleDataFromServer(updateRows);
					if (getCurFragment() instanceof PackingFragment)
						this.reloadCurFragment();
				} else {
					showToast(((BaseSyncWS) wsControl)
							.parseFaultMessage(result));
				}
			}
			break;
		case BaseWS.SYNC_GROUP:
			break;
		case BaseWS.SYNC_PHOTO:
			Fragment currentFragment = getSupportFragmentManager()
					.findFragmentById(R.id.content_frame);
			if (currentFragment instanceof HomeTripFragment) {
				((HomeTripFragment) currentFragment).updatePhotoCount();
			}
			break;
		case BaseWS.ADD_TRIP:
			int tripId = (Integer) wsControl.parseData(result);
			if (tripId != -1) {
				((TravelApplication) this.getApplication()).setTripAdded(true);
				TravelPrefs.putData(this, TravelPrefs.PREF_TRIP_ID, tripId);
				getFrequentPrefs();
				this.move2FirstScreen();
				this.changeScreen(Screen.INVITE);
			} else {
				String errorMess = AddTripWS.parseFaultMessage(result);
				showToast(errorMess.length() > 0 ? errorMess
						: getString(R.string.toast_uncaught_prob));
			}
			break;
		case BaseWS.END_TRIP:
			Pair<Integer, String> pair = (Pair<Integer, String>) wsControl
					.parseData(result);
			if (pair != null) {
				if (pair.first == 1) {
					clearDataOfTrip(this, mUserId, mTripId);
					((TravelApplication) this.getApplication())
							.setTripAdded(false);
					this.move2FirstScreen();
				} else {
					showToast(pair.second);
				}
			} else {
				showToast(getString(R.string.toast_uncaught_prob));
			}
			break;
		case BaseWS.GET_TRIP:
			Trip tripInfo = (Trip) wsControl.parseData(result);
			if (tripInfo == null) {
				clearDataOfTrip(this, mUserId, mTripId);
				this.changeScreen(Screen.HOME);
				break;
			}
			tripInfo.setTripId(mTripId);
			tripInfo.setUserId(mUserId);
			new TripTableAdapter(this).updateTrip(tripInfo);
			TravelPrefs.putData(this, TravelPrefs.PREF_GROUP_PHOTO,
					tripInfo.getNumberOfGroupPhotos());
			TravelPrefs.putData(this, TravelPrefs.PREF_TRIP_NAME,
					tripInfo.getTripName());
			this.reloadCurFragment();
			break;
		case BaseWS.GET_VERSION:
			HashMap<String, Integer> vers = (HashMap<String, Integer>) wsControl
					.parseData(result);
			if (vers == null) {
				showToast(getString(R.string.toast_uncaught_prob));
			} else {
				checkVersionAndSync(vers);
			}
			break;
		case BaseWS.GET_USER_INFO:
			List<User> listUser = (List<User>) wsControl.parseData(result);
			if (listUser != null) {
				new UserTableAdapter(this).updateTableUser(listUser);
				this.reloadCurFragment();
			}
			break;
		// case BaseWS.GET_CATEGORY:
		// List<Category> listCates = (List<Category>) wsControl
		// .parseData(result);
		// if (listCates != null) {
		// new CategoryTableAdapter(this).addListCategories(listCates);
		// if (getCurFragment() instanceof ExpensesFragment
		// || getCurFragment() instanceof AddExpensesFragment)
		// this.reloadCurFragment();
		// }
		// break;
		case BaseWS.SEND_MAIL_INVITE:
			String message = (String) wsControl.parseData(result);
			this.showToast(message == null ? getString(R.string.toast_uncaught_prob)
					: message);
			break;
		case BaseWS.REGISTER_GCM:
			String _message = (String) wsControl.parseData(result);
			if (_message == null) {
				Log.i(GCMIntentService.TAG, "Fault from server side");
			} else {
				Log.i(GCMIntentService.TAG, _message);
				GCMRegistrar.setRegisteredOnServer(this, true);
			}
			break;
		case BaseWS.REMOVE_GCM:
			String _mess = (String) wsControl.parseData(result);
			if (_mess == null) {
				Log.i(GCMIntentService.TAG, "Fault from server side");
			} else {
				Log.i(GCMIntentService.TAG, _mess);
				GCMRegistrar.setRegisteredOnServer(this, false);
			}
			break;
		case BaseWS.ADD_GROUP:
			String inviteMess = (String) wsControl.parseData(result);
			this.showToast(inviteMess == null ? getString(R.string.toast_uncaught_prob)
					: inviteMess);
			break;
		case BaseWS.GET_USERS_IN_GROUP:
			wsControl.parseData(result);
			// String groupMess = (String) wsControl.parseData(result);
			// this.showToast(groupMess == null ?
			// getString(R.string.toast_uncaught_prob)
			// : groupMess);
			break;
		case BaseWS.SEND_ALERT:
			wsControl.parseData(result);
			break;
		case BaseWS.SEND_RECEIPT:
			String receiptmessage = (String) wsControl.parseData(result);
			this.showToast(receiptmessage == null ? getString(R.string.toast_uncaught_prob)
					: receiptmessage);

			break;
		case BaseWS.ADD_BUDGET:
			double budget = (Double) wsControl.parseData(result);
			if (budget > 0) {
				new TripTableAdapter(this).setTripBudget((Integer) TravelPrefs
						.getData(this, TravelPrefs.PREF_TRIP_ID), budget);
			}

			break;
		default:
			break;
		}
	}

	public static void clearDataOfTrip(Context context, int userId, int tripId) {
		TravelPrefs.clearData(context);
		new ExpenseTableAdapter(context).deleteExpenseOfUser(userId);
		new UsersInGroupTableAdapter(context).deleteTripOfUser(tripId);
		new NoteTableAdapter(context).deleteNoteOfTrip(tripId);
		new PackingTitleTableAdapter(context).deletePackingOfUser(userId);
		new PhotoTableAdapter(context).deletePhotoOfTrip(tripId);
		new PhotoTableAdapter(context).deleteReceiptOfUser(userId);
		new TripTableAdapter(context).deleteTrip(tripId, userId);
		new VersionTableAdapter(context).deleteTripVersions(userId);
		new UserTableAdapter(context).deleteListUserInfoOfTrip(tripId, userId);
	}

	public void SyncAllData() {
		if (TravelApplication.isOnline(this)
				&& (Boolean) TravelPrefs.getData(this,
						TravelPrefs.PREF_FIRSTTIME_LOAD)) {
			new GetPremadeItemWS(MainActivity.this).fetchData();
			new GetPremadePackingWS(MainActivity.this).fetchData();
			TravelPrefs.putData(this, TravelPrefs.PREF_FIRSTTIME_LOAD, false);
		}
		if (mUserId > 0 && mTripId > 0) {
			// showProgressDialog(getString(R.string.title_update_all),
			// getString(R.string.wait_in_sec), null);
			new GetVersionWS(MainActivity.this).fetchData(mUserId, mTripId);
			new GetUserDataWS(MainActivity.this)
					.fetchData(new UserTableAdapter(this).getAllUserIdInTable());
			new GetTripWS(MainActivity.this).fetchData(mTripId, mUserId);
		}
	}

	public void checkVersionAndSync(HashMap<String, Integer> serverVers) {
		if (mUserId > 0) {
			HashMap<String, Integer> clientVers = new VersionTableAdapter(this)
					.getVersionTable(mUserId);
			List<String> versNeedSync = new ArrayList<String>();

			// sync table which have version < version server
			String[] clientKey = { ContentProviderDB.COL_VERSION_NOTE,
					ContentProviderDB.COL_VERSION_CATE,
					ContentProviderDB.COL_VERSION_EXPENSE,
					ContentProviderDB.COL_VERSION_GROUP,
					ContentProviderDB.COL_VERSION_PHOTO,
					ContentProviderDB.COL_VERSION_PACKING,
					ContentProviderDB.COL_VERSION_PACKINGITEM,
					ContentProviderDB.COL_VERSION_PREMADE_PACKING,
					ContentProviderDB.COL_VERSION_PREMADE_PACKINGITEM };
			String[] serverKey = { "note_ver", "cate_ver", "expense_ver",
					"group_ver", "photo_ver", "packingtitle_ver",
					"packingitem_ver", "premadelist_ver", "premadeitem_ver" };
			if (clientKey.length == serverKey.length)
				for (int i = 0; i < serverKey.length; i++)
					if (clientVers.get(clientKey[i]) < serverVers
							.get(serverKey[i]))
						versNeedSync.add(clientKey[i]);

			// sync table which have data is changed
			if (new NoteTableAdapter(this).checkNeedSync()) {
				if (!versNeedSync.contains(ContentProviderDB.COL_VERSION_NOTE))
					versNeedSync.add(ContentProviderDB.COL_VERSION_NOTE);
			}
			if (new ExpenseTableAdapter(this).checkNeedSync()) {
				if (!versNeedSync
						.contains(ContentProviderDB.COL_VERSION_EXPENSE))
					versNeedSync.add(ContentProviderDB.COL_VERSION_EXPENSE);
			}
			if (new PackingTitleTableAdapter(this).checkNeedSync()) {
				if (!versNeedSync
						.contains(ContentProviderDB.COL_VERSION_PACKING))
					versNeedSync.add(ContentProviderDB.COL_VERSION_PACKING);
			}
			if (new PackingItemTableAdapter(this).checkNeedSync()) {
				if (!versNeedSync
						.contains(ContentProviderDB.COL_VERSION_PACKINGITEM))
					versNeedSync.add(ContentProviderDB.COL_VERSION_PACKINGITEM);
			}
			if (new PhotoTableAdapter(this).checkNeedSync()) {
				if (!versNeedSync.contains(ContentProviderDB.COL_VERSION_PHOTO))
					versNeedSync.add(ContentProviderDB.COL_VERSION_PHOTO);
			}

			for (String ver : versNeedSync)
				callEquivalentWS(ver);
		}
	}

	/**
	 * Call webservice equivalent with table version
	 * 
	 * @param col_db
	 */
	public void callEquivalentWS(String col_db) {
		if (col_db.equals(ContentProviderDB.COL_VERSION_NOTE)) {
			NotesFragment.syncNoteData(this);
		}
		if (col_db.equals(ContentProviderDB.COL_VERSION_EXPENSE)) {
			ExpensesFragment.syncExpenseCategories(this);
		}
		if (col_db.equals(ContentProviderDB.COL_VERSION_CATE)) {
		}
		if (col_db.equals(ContentProviderDB.COL_VERSION_PACKING)) {
			PackingFragment.syncPackingTitle(this);
		}
		if (col_db.equals(ContentProviderDB.COL_VERSION_PACKINGITEM)) {
			PackingFragment.syncPackingItem(this);
		}
		if (col_db.equals(ContentProviderDB.COL_VERSION_PHOTO)) {
			if (mTripId != 0)
				SyncPhotosWS.doUpload(getApplicationContext(),
						(Integer) TravelPrefs.getData(this,
								TravelPrefs.PREF_USER_ID), mTripId);
		}
		if (col_db.equals(ContentProviderDB.COL_VERSION_GROUP)) {
			GroupFragment.getUsersInGroup(this);
		}
		if (col_db.equals(ContentProviderDB.COL_VERSION_PREMADE_PACKING)) {
		}
		if (col_db.equals(ContentProviderDB.COL_VERSION_PREMADE_PACKINGITEM)) {
		}
	}

	public int getTripId() {
		return mTripId;
	}

	public void setTripId(int mTripId) {
		this.mTripId = mTripId;
	}

	public int getUserId() {
		return mUserId;
	}

	public void setUserId(int mUserId) {
		this.mUserId = mUserId;
	}

	@Override
	protected void onNewIntent(Intent intent) {
		super.onNewIntent(intent);
		new RemoveGcmWS(MainActivity.this).fetchData(GCMRegistrar
				.getRegistrationId(MainActivity.this));
		changeScreen(Screen.LOGIN);
		((NavigationAdapter) mMenuList.getAdapter()).setSelectedPosition(0);
		TravelApplication app = ((TravelApplication) getApplication());
		app.setTripLogin(false);
		app.setTripAdded(false);
		app.setAutoLogin(true);
	}

	@Override
	public void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);
		NMSKFacebookSession.getInstance(this).onActivityResult(this,
				requestCode, resultCode, data);
	}

	@Override
	protected void onPause() {
		super.onPause();
		isPaused = true;
	}

	private void onEndTrip() {
		clearDataOfTrip(this, mUserId, mTripId);
		((TravelApplication) this.getApplication()).setTripAdded(false);
		if (!isPaused) {
			this.move2FirstScreen();
		} else {
			isReset = true;
		}
	}
}
