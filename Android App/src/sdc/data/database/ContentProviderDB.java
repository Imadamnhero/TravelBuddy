package sdc.data.database;

import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import sdc.data.database.adapter.CategoryTableAdapter;
import sdc.data.database.adapter.ExpenseTableAdapter;
import sdc.data.database.adapter.NoteTableAdapter;
import sdc.data.database.adapter.PackingItemTableAdapter;
import sdc.data.database.adapter.PackingTitleTableAdapter;
import sdc.data.database.adapter.PhotoTableAdapter;
import sdc.data.database.adapter.PremadePackingItemTableAdapter;
import sdc.data.database.adapter.PremadePackingTitleTableAdapter;
import sdc.data.database.adapter.SlideShowTableAdapter;
import sdc.data.database.adapter.TripTableAdapter;
import sdc.data.database.adapter.UserTableAdapter;
import sdc.data.database.adapter.UsersInGroupTableAdapter;
import sdc.data.database.adapter.VersionTableAdapter;
import sdc.ui.travelapp.MainActivity;
import android.content.ContentProvider;
import android.content.ContentUris;
import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.SQLException;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteException;
import android.database.sqlite.SQLiteOpenHelper;
import android.net.Uri;

import com.nostra13.universalimageloader.core.ImageLoader;

public class ContentProviderDB extends ContentProvider {

	public static final String AUTHORITY = "sdc.travebuddy.database";
	public static final Uri CONTENT_URI = Uri.parse("content://" + AUTHORITY);
	public static final String PREFIX = "travelapp_";
	public static final int FLAG_NONE = 0;
	public static final int FLAG_ADD = 1;
	public static final int FLAG_EDIT = 2;
	public static final int FLAG_DEL = 3;
	public static final int DEFAULT_SERVER_ID = 0;
	public static final String COL_SERVER_ID = PREFIX + "server_id";
	public static final String COL_FLAG = PREFIX + "flag";
	public static final String COL_ID = PREFIX + "id";
	public static final String COL_USER_ID = PREFIX + "user_id";
	public static final String COL_CATE_ID = PREFIX + "cate_id";
	public static final String COL_LOCAL_CATE_ID = PREFIX + "local_cate_id";
	public static final String COL_PACKING_ID = PREFIX + "packing_id";
	public static final String COL_PREMADE_PACKING_ID = PREFIX
			+ "prepacking_id";
	public static final String COL_COLOR = PREFIX + "color";
	public static final String COL_TRIP_ID = PREFIX + "trip_id";
	public static final String COL_TRIP_NAME = PREFIX + "tripname";
	public static final String COL_TRIP_STARTDATE = PREFIX + "startdate";
	public static final String COL_TRIP_FINISHDATE = PREFIX + "finishdate";
	public static final String COL_TRIP_BUDGET = PREFIX + "budget";
	public static final String COL_OWNER = PREFIX + "owneruser_id";
	public static final String COL_NOTE_TITLE = PREFIX + "title";
	public static final String COL_NOTE_DATETIME = PREFIX + "datetime";
	public static final String COL_NOTE_CONTENT = PREFIX + "content";
	public static final String COL_CATE_NAMECATE = PREFIX + "namecate";
	public static final String COL_EXPENSE_DATETIME = PREFIX + "datetime";
	public static final String COL_EXPENSE_MONEY = PREFIX + "money";
	public static final String COL_EXPENSE_ITEM = PREFIX + "item";
	public static final String COL_PACKING_TITLE = PREFIX + "title";
	public static final String COL_PACKING_ITEM = PREFIX + "nameitem";
	public static final String COL_PACKING_ISCHECK = PREFIX + "ischeck";
	public static final String COL_PHOTO_CAPTION = PREFIX + "caption";
	public static final String COL_PHOTO_URL = PREFIX + "urlphoto";
	public static final String COL_PHOTO_ISRECEIPT = PREFIX + "isreceipt";
	public static final String COL_VERSION_NOTE = PREFIX + "note_ver";
	public static final String COL_VERSION_EXPENSE = PREFIX + "expense_ver";
	public static final String COL_VERSION_CATE = PREFIX + "category_ver";
	public static final String COL_VERSION_PACKING = PREFIX + "packing_ver";
	public static final String COL_VERSION_PACKINGITEM = PREFIX
			+ "packing_item_ver";
	public static final String COL_VERSION_PHOTO = PREFIX + "photo_ver";
	public static final String COL_VERSION_GROUP = PREFIX + "group_ver";
	public static final String COL_VERSION_PREMADE_PACKING = PREFIX
			+ "premade_packing_ver";
	public static final String COL_VERSION_PREMADE_PACKINGITEM = PREFIX
			+ "premade_packingitem_ver";
	public static final String COL_USER_NAME = PREFIX + "name";
	public static final String COL_USER_AVATAR = PREFIX + "avatar";
	public static final String COL_GROUP_PENDING = PREFIX + "pending_stt";
	public static final String COL_ALLOW_UP = PREFIX + "alow_up";
	public static final String COL_FILE_PATH ="file_path";
	public static final String COL_SERVER_PATH = "server_path";
	public static final String COL_THUMB = "thumb";
	private DatabaseHelper mDbHelper;

	private class DatabaseHelper extends SQLiteOpenHelper {
		private static final String DATABASE_NAME = "TravelAppDatabase";
		private static final int DATABASE_VERSION = 1;
		private String DB_PATH;
		private SQLiteDatabase dataBase;

		public DatabaseHelper(Context context) {
			super(context, DATABASE_NAME, null, DATABASE_VERSION);
			DB_PATH = "/data/data/"
					+ getContext().getApplicationContext().getPackageName()
					+ "/databases/";
		}

		@Override
		public void onCreate(SQLiteDatabase database) {
			database.execSQL(CategoryTableAdapter.CREATE_TABLE);
			database.execSQL(ExpenseTableAdapter.CREATE_TABLE);
			database.execSQL(UsersInGroupTableAdapter.CREATE_TABLE);
			database.execSQL(NoteTableAdapter.CREATE_TABLE);
			database.execSQL(PackingItemTableAdapter.CREATE_TABLE);
			database.execSQL(PackingTitleTableAdapter.CREATE_TABLE);
			database.execSQL(PhotoTableAdapter.CREATE_TABLE);
			database.execSQL(PremadePackingTitleTableAdapter.CREATE_TABLE);
			database.execSQL(PremadePackingItemTableAdapter.CREATE_TABLE);
			database.execSQL(TripTableAdapter.CREATE_TABLE);
			database.execSQL(VersionTableAdapter.CREATE_TABLE);
			database.execSQL(UserTableAdapter.CREATE_TABLE);
			database.execSQL(SlideShowTableAdapter.CREATE_TABLE);
		}

		@Override
		public void onUpgrade(SQLiteDatabase database, int oldVersion,
				int newVersion) {
			database.execSQL("DROP TABLE IF EXISTS "
					+ CategoryTableAdapter.TABLE_NAME);
			database.execSQL("DROP TABLE IF EXISTS "
					+ ExpenseTableAdapter.TABLE_NAME);
			database.execSQL("DROP TABLE IF EXISTS "
					+ UsersInGroupTableAdapter.TABLE_NAME);
			database.execSQL("DROP TABLE IF EXISTS "
					+ NoteTableAdapter.TABLE_NAME);
			database.execSQL("DROP TABLE IF EXISTS "
					+ PackingItemTableAdapter.TABLE_NAME);
			database.execSQL("DROP TABLE IF EXISTS "
					+ PackingTitleTableAdapter.TABLE_NAME);
			database.execSQL("DROP TABLE IF EXISTS "
					+ PhotoTableAdapter.TABLE_NAME);
			database.execSQL("DROP TABLE IF EXISTS "
					+ PremadePackingTitleTableAdapter.TABLE_NAME);
			database.execSQL("DROP TABLE IF EXISTS "
					+ PremadePackingItemTableAdapter.TABLE_NAME);
			database.execSQL("DROP TABLE IF EXISTS "
					+ TripTableAdapter.TABLE_NAME);
			database.execSQL("DROP TABLE IF EXISTS "
					+ VersionTableAdapter.TABLE_NAME);
			database.execSQL("DROP TABLE IF EXISTS "
					+ NoteTableAdapter.TABLE_NAME);
			database.execSQL("DROP TABLE IF EXISTS "
					+ UserTableAdapter.TABLE_NAME);
			onCreate(database);
		}

		@Override
		public synchronized void close() {
			if (dataBase != null)
				dataBase.close();
			super.close();
		}

		public boolean createDataBase() {
			boolean dbExist = checkDataBase();
			if (!dbExist) {
				this.getReadableDatabase();
				try {
					copyDataBase();
				} catch (IOException e) {
					e.printStackTrace();
					return false;
				}
			}
			return true;
		}

		private boolean checkDataBase() {
			SQLiteDatabase checkDB = null;
			try {
				String myPath = DB_PATH + DATABASE_NAME;
				checkDB = SQLiteDatabase.openDatabase(myPath, null,
						SQLiteDatabase.OPEN_READONLY);

			} catch (SQLiteException e) {
				if (checkDB != null) {
					checkDB.close();
				}
			}
			if (checkDB != null) {
				checkDB.close();
			}
			return checkDB != null ? true : false;
		}

		private void copyDataBase() throws IOException {
			InputStream myInput = getContext().getAssets().open(DATABASE_NAME);
			String outFileName = DB_PATH + DATABASE_NAME;
			OutputStream myOutput = new FileOutputStream(outFileName);
			byte[] buffer = new byte[1024];
			int length;
			while ((length = myInput.read(buffer)) > 0) {
				myOutput.write(buffer, 0, length);
			}
			myOutput.flush();
			myOutput.close();
			myInput.close();
		}

	}

	@Override
	public int delete(Uri uri, String where, String[] selectionArgs) {
		String table = getTableName(uri);
		SQLiteDatabase dataBase = mDbHelper.getWritableDatabase();
		return dataBase.delete(table, where, selectionArgs);
	}

	@Override
	public String getType(Uri uri) {
		return null;
	}

	@Override
	public Uri insert(Uri uri, ContentValues values) {
		SQLiteDatabase mDB = mDbHelper.getWritableDatabase();
		long rowID = mDB.insert(getTableName(uri), null, values);
		if (rowID > 0) {
			Uri _uri = ContentUris.withAppendedId(CONTENT_URI, rowID);
			getContext().getContentResolver().notifyChange(_uri, null);
			return _uri;
		}
		throw new SQLException("Failed to add a record into " + uri);
	}

	@Override
	public boolean onCreate() {
		mDbHelper = new DatabaseHelper(getContext());
		if (mDbHelper != null) {
			mDbHelper.createDataBase();
			return false;
		} else
			return true;

	}

	@Override
	public Cursor query(Uri uri, String[] projection, String selection,
			String[] selectionArgs, String sortOrder) {
		String table = getTableName(uri);
		SQLiteDatabase database = mDbHelper.getReadableDatabase();
		Cursor cursor = database.query(table, projection, selection,
				selectionArgs, null, null, sortOrder);
		return cursor;
	}

	@Override
	public int update(Uri uri, ContentValues values, String selection,
			String[] selectionArgs) {
		String table = getTableName(uri);
		SQLiteDatabase database = mDbHelper.getWritableDatabase();
		return database.update(table, values, selection, selectionArgs);
	}

	public String getTableName(Uri uri) {
		String value = uri.getLastPathSegment();
		return value;
	}

	public static void clearAllData(MainActivity context) {
		new CategoryTableAdapter(context).clearTable();
		new ExpenseTableAdapter(context).clearTable();
		new UsersInGroupTableAdapter(context).clearTable();
		new NoteTableAdapter(context).clearTable();
		new PackingItemTableAdapter(context).clearTable();
		new PackingTitleTableAdapter(context).clearTable();
		new PhotoTableAdapter(context).clearTable();
		new PremadePackingTitleTableAdapter(context).clearTable();
		new PremadePackingItemTableAdapter(context).clearTable();
		new TripTableAdapter(context).clearTable();
		new VersionTableAdapter(context).clearTable();
		new UserTableAdapter(context).clearTable();
		ImageLoader.getInstance().clearMemoryCache();
		ImageLoader.getInstance().clearDiscCache();
	}

}