package sdc.net.listeners;

import sdc.net.webservice.BaseWS;

public interface IWebServiceListener {

	public void onConnectionOpen(int type);

	@SuppressWarnings("rawtypes")
	public void onConnectionDone(BaseWS wsControl, int type, String result);

	public void onConnectionError(int type, String fault);
}
