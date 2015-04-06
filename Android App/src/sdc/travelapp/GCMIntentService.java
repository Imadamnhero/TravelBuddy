package sdc.travelapp;

import java.util.Date;

import org.json.JSONException;
import org.json.JSONObject;

import sdc.application.TravelPrefs;
import sdc.data.Trip;
import sdc.data.User;
import sdc.data.database.ContentProviderDB;
import sdc.data.database.adapter.TripTableAdapter;
import sdc.data.database.adapter.UserTableAdapter;
import sdc.data.database.adapter.UsersInGroupTableAdapter;
import sdc.data.database.adapter.VersionTableAdapter;
import sdc.net.listeners.IWebServiceListener;
import sdc.net.webservice.BaseWS;
import sdc.net.webservice.GetUsersInGroupWS;
import sdc.ui.activity.InvitationActivity;
import sdc.ui.travelapp.MainActivity;
import sdc.ui.utils.GraphicUtils;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.support.v4.app.NotificationCompat;
import android.util.Log;
import android.widget.RemoteViews;
import android.widget.Toast;

import com.google.android.gcm.GCMBaseIntentService;
import com.google.android.gcm.GCMRegistrar;
import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;

public class GCMIntentService extends GCMBaseIntentService implements
		IWebServiceListener {
	private static int mId = 1;
	public static final String TAG = "GCMIntentService";

	public GCMIntentService() {
		super(GCMUtils.GCM_SENDER_ID);
	}

	/**
	 * Method called on device registered
	 **/
	@Override
	protected void onRegistered(Context context, String registrationId) {
		Log.i(TAG, "Device registered");
		GCMUtils.register(context, registrationId, this);
	}

	/**
	 * Method called on device unregistred
	 * */
	@Override
	protected void onUnregistered(Context context, String registrationId) {
		Log.i(TAG, "Device unregistered");
		GCMUtils.unregister(this, registrationId);
	}

	/**
	 * Method called on Receiving a new message
	 * */
	@Override
	protected void onMessage(Context context, Intent intent) {
		Log.i(TAG, "Received message");
		String message = intent.getExtras().getString("message");
		if (message != null) {
			try {
				JSONObject messageJSON = new JSONObject(message);
				int type = messageJSON.getInt("type");
				int user_id = (Integer) TravelPrefs.getData(context,
						TravelPrefs.PREF_USER_ID);
				int trip_id = (Integer) TravelPrefs.getData(context,
						TravelPrefs.PREF_TRIP_ID);
				if (type == 1) { // add group
					int invited_id = messageJSON.getInt("invited_user_id");
					if (user_id == invited_id) {
						int inviter_id = messageJSON.getInt("inviter_id");
						String tripName = messageJSON.getString("tripname");
						String inviter_avatar = messageJSON
								.getString("inviter_avatar");
						String inviter_name = messageJSON
								.getString("inviter_name");
						int tripId = messageJSON.getInt("tripid");
						User inviter_info = new User(inviter_id,
								inviter_avatar, inviter_name, tripId, tripName);
						new UserTableAdapter(context).updateUser(inviter_info);
						showNotificationInviteToGroup(context,
								new Date().getTime(), inviter_info, invited_id);
					}
				} else if (type == 2) { // response accept or decline
					int clientVer = new VersionTableAdapter(context)
							.getVersionTableofUser(user_id,
									ContentProviderDB.COL_VERSION_GROUP);

					String avatar = messageJSON.getString("inviter_avatar");
					String userName = messageJSON.getString("inviter_name");
					int reply = messageJSON.getInt("reply");
					showNotificationAccept(
							this,
							userName,
							reply != 0 ? getString(
									R.string.toast_accepted_invitation,
									userName) : getString(
									R.string.toast_declined_invitation,
									userName), avatar, new Date().getTime());

					new GetUsersInGroupWS(this, context).fetchData(trip_id,
							clientVer);
					// Intent newIntent = new Intent(context,
					// MainActivity.class);
					// context.startActivity(newIntent);
				} else if (type == 3) { // alert
					String content = messageJSON.getString("content");
					String sender_name = messageJSON.getString("sender_name");
					String sender_avatar = messageJSON
							.getString("sender_avatar");
					showNotificationAlert(context, sender_name, content,
							sender_avatar, new Date().getTime());
				} else if (type == 0) { // end trip
					// String endTripMsg = obj.getString("message");

					int mTripId = (Integer) TravelPrefs.getData(this,
							TravelPrefs.PREF_TRIP_ID);
					int mUserId = (Integer) TravelPrefs.getData(this,
							TravelPrefs.PREF_USER_ID);
					int tripId = messageJSON.getInt("trip_id");
					int userId = messageJSON.getInt("user_id");
					String userName = messageJSON.getString("user_name");
					String userAvatar = messageJSON.getString("user_avatar");
					if (mTripId != 0 && mTripId == tripId) {
						Trip mTripInfo = new TripTableAdapter(context).getTrip(
								mTripId, mUserId);
						String msg = getString(R.string.toast_end_trip_owner,
								userName, mTripInfo.getTripName());
						if (mUserId != userId)
							showNotificationEndTrip(context, userName,
									userAvatar, msg, new Date().getTime());
						boolean isOwner = messageJSON.getInt("is_owner") == 1;
						new UsersInGroupTableAdapter(context)
								.deleteUsersInTrip(tripId, userId);
						if (isOwner) {
							MainActivity.clearDataOfTrip(context, user_id,
									trip_id);
							Intent i = new Intent(
									MainActivity.FILTER_ACTION_END_TRIP);
							intent.putExtra("msg", msg);

							sendBroadcast(i);
						}

					}
				} else if (type == 4) { // end trip
					// String endTripMsg = obj.getString("message");

					int userId = messageJSON.getInt("user_id");
					String userName = messageJSON.getString("user_name");
					String userAvatar = messageJSON.getString("user_avatar");
					UserTableAdapter adapter = new UserTableAdapter(this);
					adapter.updateUser(new User(userId, userAvatar, userName));

				}
			} catch (JSONException e) {
				e.printStackTrace();
			}
		}
	}

	/**
	 * Method called on receiving a deleted message
	 * */
	@Override
	protected void onDeletedMessages(Context context, int total) {
		Log.i(TAG, "Received deleted messages notification");
	}

	/**
	 * Method called on Error
	 * */
	@Override
	public void onError(Context context, String errorId) {
		Log.i(TAG, "Received error: " + errorId);
	}

	@Override
	protected boolean onRecoverableError(Context context, String errorId) {
		// log message
		Log.i(TAG, "Received recoverable error: " + errorId);
		return super.onRecoverableError(context, errorId);
	}

	@SuppressWarnings("rawtypes")
	@Override
	public void onConnectionDone(BaseWS wsControl, int type, String result) {
		switch (type) {
		case BaseWS.REGISTER_GCM:
			String _message = (String) wsControl.parseData(result);
			if (_message == null) {
				Log.i(TAG, "Fault from server side");
			} else {
				Log.i(TAG, _message);
				GCMRegistrar.setRegisteredOnServer(this, true);
			}
			break;
		case BaseWS.REMOVE_GCM:
			String _mess = (String) wsControl.parseData(result);
			if (_mess == null) {
				Log.i(TAG, "Fault from server side");
			} else {
				Log.i(TAG, _mess);
				GCMRegistrar.setRegisteredOnServer(this, false);
			}
			break;
		case BaseWS.GET_USERS_IN_GROUP:
			wsControl.parseData(result);
			break;
		default:
			break;
		}
	}

	@Override
	public void onConnectionError(int type, String fault) {
		Toast.makeText(this, getString(R.string.toast_problem_network),
				Toast.LENGTH_SHORT).show();
	}

	@Override
	public void onConnectionOpen(int type) {

	}

	public static void showNotificationInviteToGroup(Context context,
			long when, User userInfo, int invitedId) {
		DisplayImageOptions options = new DisplayImageOptions.Builder()
				.cacheOnDisc(true).build();
		NotificationManager notificationManager = (NotificationManager) context
				.getSystemService(Context.NOTIFICATION_SERVICE);
		Intent notificationIntent;
		String notifyMsg = context.getString(R.string.msg_invite_trip,
				userInfo.getName(), userInfo.getTripName(),
				userInfo.getTripName());
		String confirmMsg = context.getString(R.string.msg_join_trip,
				userInfo.getTripName());
		notificationIntent = new Intent(context, InvitationActivity.class);
		notificationIntent.setFlags(Intent.FLAG_ACTIVITY_BROUGHT_TO_FRONT);
		notificationIntent.putExtra("msg", notifyMsg);
		notificationIntent.putExtra("msg2", confirmMsg);
		notificationIntent.putExtra("avatar", userInfo.getAvatar());
		notificationIntent.putExtra("tripid", userInfo.getTripId());
		notificationIntent.putExtra("inviter_id", userInfo.getId());
		notificationIntent.putExtra("invited_id", invitedId);
		// set intent so it does not start a new activity
		// PendingIntent resultPendingIntent =
		// PendingIntent.getBroadcast(context,
		// mId, notificationIntent, 0);
		PendingIntent resultPendingIntent = PendingIntent.getActivity(context,
				mId, notificationIntent, Intent.FLAG_ACTIVITY_NEW_TASK);
		Bitmap bitmapAva = ImageLoader.getInstance().loadImageSync(
				BaseWS.HOST + userInfo.getAvatar(), options);
		Bitmap cropAva;
		if (bitmapAva != null)
			cropAva = GraphicUtils.cropBitmap(context, bitmapAva);
		else {
			cropAva = GraphicUtils.cropBitmap(context, BitmapFactory
					.decodeResource(context.getResources(),
							R.drawable.default_avatar));
		}
		NotificationCompat.Builder builder = new NotificationCompat.Builder(
				context)
				.setContentTitle(context.getString(R.string.app_name))
				.setContentText(
						context.getString(R.string.msg_invite_trip2,
								userInfo.getName(), userInfo.getTripName()))
				.setLargeIcon(cropAva).setSmallIcon(R.drawable.ic_launcher)
				.setWhen(when).setContentIntent(resultPendingIntent);
		Notification notification = builder.build();

		notification.flags |= Notification.FLAG_AUTO_CANCEL;
		notification.defaults |= Notification.DEFAULT_SOUND;
		// notification.sound = Uri.parse("android.resource://" +
		// context.getPackageName() + "your_sound_file_name.mp3");

		notification.defaults |= Notification.DEFAULT_VIBRATE;

		notificationManager.notify(mId, notification);
		mId++;
	}

	public static void showNotificationEndTrip(Context context,
			String userName, String userAvatar, String msg, long when) {
		NotificationManager notificationManager = (NotificationManager) context
				.getSystemService(Context.NOTIFICATION_SERVICE);
		Intent notificationIntent;
		notificationIntent = new Intent(context, MainActivity.class);
		notificationIntent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP
				| Intent.FLAG_ACTIVITY_NEW_TASK
				| Intent.FLAG_ACTIVITY_CLEAR_TASK);
		PendingIntent resultPendingIntent = PendingIntent.getActivity(context,
				mId, notificationIntent, Intent.FLAG_ACTIVITY_NEW_TASK);
		DisplayImageOptions options = new DisplayImageOptions.Builder()
				.cacheOnDisc(true).build();
		Bitmap bitmapAva = ImageLoader.getInstance().loadImageSync(
				BaseWS.HOST + userAvatar, options);
		Bitmap cropAva;
		if (bitmapAva != null)
			cropAva = GraphicUtils.cropBitmap(context, bitmapAva);
		else
			cropAva = GraphicUtils.cropBitmap(context, BitmapFactory
					.decodeResource(context.getResources(),
							R.drawable.default_avatar));

		NotificationCompat.Builder builder = new NotificationCompat.Builder(
				context).setContentTitle(context.getString(R.string.app_name))
				.setContentText(msg).setSmallIcon(R.drawable.ic_launcher)
				.setLargeIcon(cropAva).setWhen(when)
				.setContentIntent(resultPendingIntent);
		Notification notification = builder.build();
		notification.flags |= Notification.FLAG_AUTO_CANCEL;
		notification.defaults |= Notification.DEFAULT_SOUND;
		notification.defaults |= Notification.DEFAULT_VIBRATE;
		notificationManager.notify(mId, notification);
		mId++;
	}

	public static void showNotificationAlert(Context context,
			String nameOfSender, String content, String avatarOfSender,
			long when) {
		DisplayImageOptions options = new DisplayImageOptions.Builder()
				.cacheOnDisc(true).build();
		NotificationManager notificationManager = (NotificationManager) context
				.getSystemService(Context.NOTIFICATION_SERVICE);
		Bitmap bitmapAva = ImageLoader.getInstance().loadImageSync(
				BaseWS.HOST + avatarOfSender, options);
		Bitmap cropAva;
		if (bitmapAva != null)
			cropAva = GraphicUtils.cropBitmap(context, bitmapAva);
		else
			cropAva = GraphicUtils.cropBitmap(context, BitmapFactory
					.decodeResource(context.getResources(),
							R.drawable.default_avatar));
		NotificationCompat.Builder builder = new NotificationCompat.Builder(
				context).setContentTitle(nameOfSender).setContentText(content)
				.setSmallIcon(R.drawable.ic_launcher).setWhen(when)
				.setLargeIcon(cropAva);
		Notification notification = builder.build();
		notification.flags |= Notification.FLAG_AUTO_CANCEL;
		notification.defaults |= Notification.DEFAULT_SOUND;
		notification.defaults |= Notification.DEFAULT_VIBRATE;
		notificationManager.notify(mId, notification);
		mId++;
	}

	public static void showNotificationAccept(Context context,
			String nameOfSender, String content, String avatarOfSender,
			long when) {
		DisplayImageOptions options = new DisplayImageOptions.Builder()
				.cacheOnDisc(true).build();
		NotificationManager notificationManager = (NotificationManager) context
				.getSystemService(Context.NOTIFICATION_SERVICE);
		Bitmap bitmapAva = ImageLoader.getInstance().loadImageSync(
				BaseWS.HOST + avatarOfSender, options);
		Bitmap cropAva;
		if (bitmapAva != null)
			cropAva = GraphicUtils.cropBitmap(context, bitmapAva);
		else
			cropAva = GraphicUtils.cropBitmap(context, BitmapFactory
					.decodeResource(context.getResources(),
							R.drawable.default_avatar));

		Intent notificationIntent;
		notificationIntent = new Intent(context, MainActivity.class);
		notificationIntent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP
				| Intent.FLAG_ACTIVITY_NEW_TASK
				| Intent.FLAG_ACTIVITY_CLEAR_TASK);
		notificationIntent.putExtra("is_group", true);

		PendingIntent resultPendingIntent = PendingIntent.getActivity(context,
				mId, notificationIntent, Intent.FLAG_ACTIVITY_NEW_TASK);

		NotificationCompat.Builder builder = new NotificationCompat.Builder(
				context).setContentTitle(nameOfSender).setContentText(content)
				.setSmallIcon(R.drawable.ic_launcher).setWhen(when)
				.setLargeIcon(cropAva).setContentIntent(resultPendingIntent);
		Notification notification = builder.build();
		notification.flags |= Notification.FLAG_AUTO_CANCEL;
		notification.defaults |= Notification.DEFAULT_SOUND;
		notification.defaults |= Notification.DEFAULT_VIBRATE;
		notificationManager.notify(mId, notification);
		mId++;
	}

	public static void showCustomNotification(Context context,
			String nameOfSender, String content, String avatarOfSender,
			long when) {
		// Using RemoteViews to bind custom layouts into Notification
		RemoteViews remoteViews = new RemoteViews(context.getPackageName(),
				R.layout.custom_notification);

		NotificationCompat.Builder builder = new NotificationCompat.Builder(
				context)
		// Set Icon
				.setSmallIcon(R.drawable.ic_launcher)
				// Set RemoteViews into Notification
				.setContent(remoteViews);

		// Locate and set the Image into customnotificationtext.xml ImageViews
		remoteViews.setImageViewResource(R.id.imagenotileft,
				R.drawable.ic_launcher);
		remoteViews.setImageViewResource(R.id.imagenotiright,
				R.drawable.ic_launcher);

		// Locate and set the Text into customnotificationtext.xml TextViews
		remoteViews.setTextViewText(R.id.title, nameOfSender);
		remoteViews.setTextViewText(R.id.text, content);

		// Create Notification Manager
		NotificationManager notificationManager = (NotificationManager) context
				.getSystemService(NOTIFICATION_SERVICE);
		// Build Notification with Notification Manager
		Notification notification = builder.build();
		notification.flags |= Notification.FLAG_AUTO_CANCEL;
		notification.defaults |= Notification.DEFAULT_SOUND;
		notification.defaults |= Notification.DEFAULT_VIBRATE;
		notificationManager.notify(mId, notification);
		mId++;
	}

}
