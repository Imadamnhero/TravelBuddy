package sdc.ui.adapter;

import java.util.ArrayList;
import java.util.List;

import sdc.travelapp.R;
import android.annotation.SuppressLint;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.Button;

/**
 * Adapter is fundamental for SwipeListView
 * 
 * @author baolong
 * 
 */
public class BaseArrayAdapter<T> extends ArrayAdapter<T> {
	List<T> mData;
	int mResource;

	public BaseArrayAdapter(Context context, int resource, List<T> data) {
		super(context, resource, data);
		mData = data;
		mResource = resource;
	}

	public BaseArrayAdapter(Context context, int resource, T[] data) {
		super(context, resource, data);
		mData = new ArrayList<T>();
		for (T t : data)
			mData.add(t);
		mResource = resource;
	}

	@SuppressLint("ViewHolder")
	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		LayoutInflater inflater = LayoutInflater.from(getContext());
		convertView = inflater.inflate(mResource, parent, false);
		Button btnDelete = (Button) convertView.findViewById(R.id.btn1);
		btnDelete
				.setOnClickListener(new OnButtonDeleteClick(getItem(position)));
		return convertView;
	}

	@Override
	public int getCount() {
		return mData.size();
	}

	@Override
	public T getItem(int position) {
		return mData.get(position);
	}

	public void removeItem(int position) {
		mData.remove(position);
		notifyDataSetChanged();
	}

	protected class OnButtonDeleteClick implements View.OnClickListener {
		T mItem;

		public OnButtonDeleteClick(T item) {
			mItem = item;
		}

		@Override
		public void onClick(View v) {
			remove(mItem);
			notifyDataSetChanged();
		}
	}
}
