package sdc.net.utils;

import java.util.List;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import sdc.data.Category;
import sdc.data.Expense;
import sdc.data.Note;
import sdc.data.Packing;
import sdc.data.PackingItem;
import sdc.ui.utils.DateTimeUtils;

public class JSONParseUtils {

	public static JSONArray convertNoteToJSONArray(List<Note> listNote) {
		JSONArray arrNote = new JSONArray();
		if (listNote != null) {
			try {
				for (Note note : listNote) {
					JSONObject obj = new JSONObject();
					obj.put("clientid", note.getId());
					obj.put("title", note.getTitle());
					obj.put("time",
							DateTimeUtils.getDateForSubmit(note.getTime()));
					obj.put("content", note.getContent());
					obj.put("ownerid", note.getOwnerId());
					obj.put("tripid", note.getTripId());
					obj.put("serverid", note.getServerId());
					obj.put("flag", note.getFlag());
					arrNote.put(obj);
				}
			} catch (JSONException e) {
			}
		}
		return arrNote;
	}

	public static JSONArray convertExpensesToJSONArray(
			List<Expense> listExpense, int tripId) {
		JSONArray arr = new JSONArray();
		if (listExpense != null) {
			try {
				for (Expense expense : listExpense) {
					JSONObject obj = new JSONObject();
					obj.put("clientid", expense.getId());
					obj.put("cateid", expense.getCateId());
					obj.put("time", expense.getDate());
					obj.put("item", expense.getItem());
					obj.put("ownerid", expense.getOwnerId());
					obj.put("money", expense.getMoney());
					obj.put("tripid", tripId);
					obj.put("serverid", expense.getServerId());
					obj.put("flag", expense.getFlag());
					arr.put(obj);
				}
			} catch (JSONException e) {
			}
		}
		return arr;
	}
	public static JSONArray convertCategoriesToJSONArray(
			List<Category> categories) {
		JSONArray arr = new JSONArray();
		if (categories != null) {
			try {
				for (Category category : categories) {
					JSONObject obj = new JSONObject();
					obj.put("clientid", category.getLocalId());
					obj.put("name", category.getNameCate());
					obj.put("user_id", category.getUserId());
					obj.put("serverid", category.getId());
					obj.put("flag", category.getFlag());
					arr.put(obj);
				}
			} catch (JSONException e) {
			}
		}
		return arr;
	}

	public static JSONArray convertPackingTitlesToJSONArray(
			List<Packing> listPacking, int tripId) {
		JSONArray arr = new JSONArray();
		if (listPacking != null) {
			try {
				for (Packing packing : listPacking) {
					JSONObject obj = new JSONObject();
					obj.put("clientid", packing.getId());
					obj.put("title", packing.getTitle());
					obj.put("ownerid", packing.getOwnerId());
					obj.put("tripid", tripId);
					obj.put("serverid", packing.getServerId());
					obj.put("flag", packing.getFlag());
					arr.put(obj);
				}
			} catch (JSONException e) {
			}
		}
		return arr;
	}

	public static JSONArray convertPackingItemToJSONArray(
			List<PackingItem> listPacking) {
		JSONArray arr = new JSONArray();
		if (listPacking != null) {
			try {
				for (PackingItem packing : listPacking) {
					JSONObject obj = new JSONObject();
					obj.put("clientid", packing.getId());
					obj.put("item", packing.getItem());
					obj.put("listid", packing.getListId());
					obj.put("ischecked", packing.isCheck() ? 1 : 0);
					obj.put("serverid", packing.getServerId());
					obj.put("flag", packing.getFlag());
					arr.put(obj);
				}
			} catch (JSONException e) {
			}
		}
		return arr;
	}
}
