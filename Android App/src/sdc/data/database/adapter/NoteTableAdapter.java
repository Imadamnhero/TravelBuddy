package sdc.data.database.adapter;

import java.util.ArrayList;
import java.util.List;

import sdc.data.Note;
import sdc.data.database.ContentProviderDB;
import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;

public class NoteTableAdapter extends BaseTableAdapter {

	public static final String TABLE_NAME = ContentProviderDB.PREFIX + "notes";

	public static final String CREATE_TABLE = "CREATE TABLE IF NOT EXISTS "
			+ TABLE_NAME + " (" + ContentProviderDB.COL_ID
			+ " integer primary key autoincrement, "
			+ ContentProviderDB.COL_NOTE_TITLE + " text, "
			+ ContentProviderDB.COL_NOTE_DATETIME + " integer, "
			+ ContentProviderDB.COL_NOTE_CONTENT + " text, "
			+ ContentProviderDB.COL_OWNER + " integer, "
			+ ContentProviderDB.COL_TRIP_ID + " integer, "
			+ ContentProviderDB.COL_SERVER_ID + " integer, "
			+ ContentProviderDB.COL_FLAG + " integer)";

	public NoteTableAdapter(Context context) {
		super(context, TABLE_NAME);
	}

	public void addNote(Note note, int tripId, int serverId, int flag) {
		ContentValues values = new ContentValues();
		values.put(ContentProviderDB.COL_NOTE_TITLE, note.getTitle());
		values.put(ContentProviderDB.COL_NOTE_DATETIME, note.getTime());
		values.put(ContentProviderDB.COL_NOTE_CONTENT, note.getContent());
		values.put(ContentProviderDB.COL_OWNER, note.getOwnerId());
		values.put(ContentProviderDB.COL_TRIP_ID, tripId);
		values.put(ContentProviderDB.COL_SERVER_ID, serverId);
		values.put(ContentProviderDB.COL_FLAG, flag);
		super.insert(values);
	}

	public void handleDataFromServer(List<Note> listNote) {
		for (Note note : listNote) {
			if (note.getFlag() == ContentProviderDB.FLAG_EDIT
					|| note.getFlag() == ContentProviderDB.FLAG_ADD) {
				insertOrUpdateNote(note, note.getServerId(), note.getTripId());
			} else {
				super.delete(
						ContentProviderDB.COL_SERVER_ID + "="
								+ note.getServerId(), null);
			}
		}
	}

	/**
	 * If a row from server is exist in table, that row will be updated. If not
	 * exist, it will be inserted
	 * 
	 * @param note
	 * @param serverId
	 * @param tripId
	 */
	public void insertOrUpdateNote(Note note, int serverId, int tripId) {
		ContentValues values = new ContentValues();
		values.put(ContentProviderDB.COL_NOTE_TITLE, note.getTitle());
		values.put(ContentProviderDB.COL_NOTE_DATETIME, note.getTime());
		values.put(ContentProviderDB.COL_NOTE_CONTENT, note.getContent());
		values.put(ContentProviderDB.COL_OWNER, note.getOwnerId());
		values.put(ContentProviderDB.COL_TRIP_ID, tripId);
		values.put(ContentProviderDB.COL_SERVER_ID, serverId);
		values.put(ContentProviderDB.COL_FLAG, ContentProviderDB.FLAG_NONE);
		if (super.update(values, ContentProviderDB.COL_SERVER_ID + "="
				+ serverId, null) <= 0) {
			super.insert(values);
		}
	}

	public List<Note> getNotesInATrip(int tripId) {
		Cursor cursor = super.query(null, ContentProviderDB.COL_TRIP_ID + "="
				+ tripId + " AND " + ContentProviderDB.COL_FLAG + " <> "
				+ ContentProviderDB.FLAG_DEL, null,
				ContentProviderDB.COL_NOTE_DATETIME);
		if (cursor.moveToFirst()) {
			List<Note> result = new ArrayList<Note>();
			do {
				int id = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_ID));
				String title = cursor.getString(cursor
						.getColumnIndex(ContentProviderDB.COL_NOTE_TITLE));
				String content = cursor.getString(cursor
						.getColumnIndex(ContentProviderDB.COL_NOTE_CONTENT));
				long time = cursor.getLong(cursor
						.getColumnIndex(ContentProviderDB.COL_NOTE_DATETIME));
				int userId = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_OWNER));
				result.add(new Note(id, title, content, time, userId));
			} while (cursor.moveToNext());
			return result;
		}
		return null;
	}

	public void deleteNoteOfTrip(int tripId) {
		super.delete(ContentProviderDB.COL_TRIP_ID + "=" + tripId, null);
	}

	public List<Note> getNotesNeedUpload() {
		Cursor cursor = super.query(null, ContentProviderDB.COL_FLAG + " <> "
				+ ContentProviderDB.FLAG_NONE, null,
				ContentProviderDB.COL_NOTE_DATETIME);
		if (cursor.moveToFirst()) {
			List<Note> listNote = new ArrayList<Note>();
			do {
				int id = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_ID));
				String title = cursor.getString(cursor
						.getColumnIndex(ContentProviderDB.COL_NOTE_TITLE));
				long datetime = cursor.getLong(cursor
						.getColumnIndex(ContentProviderDB.COL_NOTE_DATETIME));
				String content = cursor.getString(cursor
						.getColumnIndex(ContentProviderDB.COL_NOTE_CONTENT));
				int ownerId = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_OWNER));
				int tripId = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_TRIP_ID));
				int serverId = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_SERVER_ID));
				int flag = cursor.getInt(cursor
						.getColumnIndex(ContentProviderDB.COL_FLAG));
				listNote.add(new Note(id, title, content, datetime, ownerId,
						serverId, tripId, flag));
			} while (cursor.moveToNext());
			return listNote;
		}
		return null;
	}
}
