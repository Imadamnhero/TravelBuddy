//package sdc.net.webservice;
//
//import java.util.ArrayList;
//import java.util.List;
//
//import org.json.JSONArray;
//import org.json.JSONException;
//import org.json.JSONObject;
//
//import sdc.data.Category;
//import sdc.net.listeners.IWebServiceListener;
//
//public class GetCategoriesWS extends BaseWS<List<Category>> {
//
//	public GetCategoriesWS(IWebServiceListener listener) {
//		super(listener, BaseWS.GET_CATEGORY);
//	}
//
//	@Override
//	public List<Category> parseData(String json) {
//		try {
//			JSONObject o = new JSONObject(json);
//			if (o.getInt("success") == 1) {
//				JSONArray arr = o.getJSONArray("data");
//				List<Category> result = new ArrayList<Category>();
//				for (int i = 0; i < arr.length(); i++) {
//					JSONObject obj = arr.getJSONObject(i);
//					int id = obj.getInt("id");
//					String nameCate = obj.getString("category");
//					result.add(new Category(id, nameCate));
//				}
//				return result;
//			}
//		} catch (JSONException e) {
//		}
//		return null;
//	}
//
//	public void fetchData() {
//		JSONObject data = new JSONObject();
//		fetch(data);
//	}
//}
