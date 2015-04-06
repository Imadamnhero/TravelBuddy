package sdc.net.webservice;

import sdc.net.listeners.IWebServiceListener;

public class SyncGroupWS extends BaseWS<Integer>{
	
	public SyncGroupWS(IWebServiceListener listener) {
		super(listener, BaseWS.SYNC_GROUP);
	}
	
	@Override
	public Integer parseData(String json) {
		// TODO Auto-generated method stub
		return null;
	}
	
}
