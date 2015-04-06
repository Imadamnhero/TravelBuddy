package sdc.net.webservice;

import java.util.List;

import org.apache.http.NameValuePair;
import org.json.JSONObject;

import sdc.net.listeners.IWebServiceListener;
import sdc.net.webservice.task.FetchByJSONTask;
import sdc.net.webservice.task.FetchByPairTask;

/**
 * Class is fundamental for everything class which provide manipulate with
 * webservice. But in a few case webservice need to upload image data, we use
 * multipart class instead of for this base class
 * 
 * @author baolong
 * 
 * @param <T>
 *            T is type of data return after parse json
 */
public abstract class BaseWS<T> {

	public static final int LOGIN = 0;
	public static final int CREATE_USER = 1;
	public static final int EDIT_ACC = 2;
	public static final int SYNC_NOTE = 3;
	public static final int SYNC_EXPENSE = 6;
	public static final int GET_PREMADE_LIST = 9;
	public static final int GET_PREMADE_ITEM = 10;
	public static final int SYNC_PACKING_LIST = 11;
	public static final int SYNC_PACKING_ITEM = 12;
	public static final int SYNC_GROUP = 13;
	public static final int SYNC_PHOTO = 17;
	public static final int ADD_TRIP = 20;
	public static final int GET_TRIP = 21;
	public static final int END_TRIP = 22;
	public static final int GET_USER_INFO = 23;
	public static final int FORGOT_PASS = 24;
	public static final int GET_VERSION = 25;
	public static final int EDIT_TRIPNAME = 26;
	public static final int GET_CATEGORY = 27;
	public static final int SEND_MAIL_INVITE = 28;
	public static final int REMOVE_GCM = 29;
	public static final int REGISTER_GCM = 30;
	public static final int REPLY_INVITE = 31;
	public static final int ADD_GROUP = 32;
	public static final int GET_USERS_IN_GROUP = 33;
	public static final int SEND_ALERT = 34;
	public static final int ADD_BUDGET = 35;
	public static final int SEND_RECEIPT = 36;
	public static final int CREATE_SLIDESHOW = 37;
	public static final int SYNC_CATEGORIES = 38;
	public static final String HOST =  "http://tbuddy.arvixevps.com:83/";
//	"http://sdc.ud.edu.vn/sdcdevelopment/TravelBuddy/";// "http://222.255.130.149/travelbuddy/";
														// //
														// "http://192.168.2.125/travelbuddy"
	public static final String HOST_URL = "http://tbuddy.arvixevps.com:83";
	//"http://sdc.ud.edu.vn/sdcdevelopment/TravelBuddy";// "http://222.255.130.149/travelbuddy";//
														// "http://sdc.ud.edu.vn/sdcdevelopment/TravelBuddy";

	protected IWebServiceListener mListener;
	protected int mType;
	protected FetchByPairTask mPairTask;
	protected FetchByJSONTask mJSONTask;

	public BaseWS(IWebServiceListener listener, int typeOfService) {
		mListener = listener;
		mType = typeOfService;
	}

	public abstract T parseData(String json);

	@SuppressWarnings("unchecked")
	protected void fetch(List<NameValuePair> data) {
		cancelFetchTask();
		mPairTask = new FetchByPairTask(this, mListener, mType);
		mPairTask.execute(data);
	}

	protected void fetch(JSONObject data) {
		cancelFetchTask();
		mJSONTask = new FetchByJSONTask(this, mListener, mType);
		mJSONTask.execute(data);
	}

	public void cancelFetchTask() {
		if (mPairTask != null)
			mPairTask.cancel(true);
		if (mJSONTask != null)
			mJSONTask.cancel(true);
	}

	/*
	 * method used for get equivalent link with function case not used is
	 * commented
	 */
	public static String getEquivalentURL(int mType) {
		switch (mType) {
		case LOGIN:
			return HOST + "login.php";
		case CREATE_USER:
			return HOST + "add_user.php";
		case ADD_TRIP:
			return HOST + "add_trip.php";
		case GET_TRIP:
			return HOST + "get_trip.php";
		case END_TRIP:
			return HOST + "end_trip.php";
		case EDIT_ACC:
			return HOST + "edit_user.php";
		case FORGOT_PASS:
			return HOST + "forgotpassword.php";
		case SYNC_NOTE:
			return HOST + "sync_note.php";
		case SYNC_EXPENSE:
			return HOST + "sync_expense.php";
		case GET_PREMADE_LIST:
			return HOST + "get_premadelist.php";
		case GET_PREMADE_ITEM:
			return HOST + "get_premadeitem.php";
		case SYNC_PACKING_LIST:
			return HOST + "sync_packingtitle.php";
		case SYNC_PACKING_ITEM:
			return HOST + "sync_packingitem.php";
		case SYNC_GROUP:
			return HOST + "";
		case SYNC_PHOTO:
			return HOST + "sync_photo.php";
		case GET_VERSION:
			return HOST + "get_versions.php";
		case GET_USER_INFO:
			return HOST + "get_users_info.php";
		case EDIT_TRIPNAME:
			return HOST + "edit_tripname.php";
		case GET_CATEGORY:
			return HOST + "get_category.php";
		case SEND_MAIL_INVITE:
			return HOST + "send_link.php";
		case REMOVE_GCM:
			return HOST + "remove_gcm.php";
		case REGISTER_GCM:
			return HOST + "register_gcm.php";
		case REPLY_INVITE:
			return HOST + "reply_invitation.php";
		case ADD_GROUP:
			return HOST + "add_group_users.php";
		case GET_USERS_IN_GROUP:
			return HOST + "get_trip_users.php";
		case ADD_BUDGET:
			return HOST + "add_budget.php";
		case SEND_ALERT:
			return HOST + "send_alert.php";
		case SEND_RECEIPT:
			return HOST + "send_receipt.php";
		case CREATE_SLIDESHOW:
			return HOST + "create_slideshow.php";
		case SYNC_CATEGORIES:
			return HOST + "sync_expense_categories.php";
		default:
			return "";
		}
	}
}
