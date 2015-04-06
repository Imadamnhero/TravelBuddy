package sdc.net.webservice.task;

import java.io.IOException;
import java.io.UnsupportedEncodingException;

import org.apache.http.HttpResponse;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.ByteArrayEntity;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.params.BasicHttpParams;
import org.apache.http.params.HttpConnectionParams;
import org.apache.http.params.HttpParams;
import org.json.JSONObject;

import sdc.net.listeners.IWebServiceListener;
import sdc.net.utils.StringUtils;
import sdc.net.webservice.BaseWS;
import android.os.AsyncTask;

/**
 * Task interact with function of webservice by JSON data
 * 
 * @author baolong
 * 
 */
@SuppressWarnings("rawtypes")
public class FetchByJSONTask extends AsyncTask<JSONObject, Void, String> {
	private IWebServiceListener mListener;
	private int mType;
	private BaseWS mWSControl;
	public static final int TIME_OUT = 15000;
	public static final int SOCKET_TIME_OUT = 15000;

	public FetchByJSONTask(BaseWS wsControl, IWebServiceListener listener,
			int type) {
		mListener = listener;
		mType = type;
		mWSControl = wsControl;
	}

	@Override
	protected void onPreExecute() {
		if (mListener != null)
			mListener.onConnectionOpen(mType);
	}

	@Override
	protected String doInBackground(JSONObject... params) {
		try {
			DefaultHttpClient httpClient = new DefaultHttpClient();
			HttpParams httpParameters = new BasicHttpParams();
			HttpConnectionParams.setConnectionTimeout(httpParameters, TIME_OUT);
			HttpConnectionParams.setSoTimeout(httpParameters, SOCKET_TIME_OUT);
			httpClient.setParams(httpParameters);
			HttpPost httpPost = new HttpPost(BaseWS.getEquivalentURL(mType));
			httpPost.setEntity(new ByteArrayEntity(params[0].toString()
					.getBytes()));
			HttpResponse httpResponse = httpClient.execute(httpPost);
			return StringUtils.readAllFromInputStream(httpResponse.getEntity()
					.getContent());
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		} catch (ClientProtocolException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}

	@Override
	protected void onPostExecute(String result) {
		if (result != null && mListener != null) {
			mListener.onConnectionDone(mWSControl, mType, result);
		} else if (mListener != null) {
			mListener.onConnectionError(mType,
					"Cannot connect to server. Please check your connection.");
		}
	}

	@Override
	protected void onCancelled() {
		super.onCancelled();
		if (mListener != null) {
			mListener.onConnectionError(mType,
					"Cannot connect to server. Please check your connection.");
		}
	}

}
