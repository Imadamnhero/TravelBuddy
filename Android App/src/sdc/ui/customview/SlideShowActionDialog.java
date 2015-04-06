package sdc.ui.customview;

import java.io.File;

import sdc.application.TravelPrefs;
import sdc.data.SlideShow;
import sdc.data.database.adapter.SlideShowTableAdapter;
import sdc.travelapp.R;
import android.app.Activity;
import android.app.Dialog;
import android.content.Intent;
import android.graphics.drawable.ColorDrawable;
import android.net.Uri;
import android.os.Bundle;
import android.text.Html;
import android.view.View;
import android.view.Window;

import com.nikmesoft.nmsharekit.NMShareKit;
import com.nikmesoft.nmsharekit.objects.NMShareMessage;
import com.nikmesoft.nmsharekit.objects.NMShareMessage.NMShareType;

public class SlideShowActionDialog extends Dialog implements
		View.OnClickListener {
	private SlideShow mSlideShow;
	private DeleteSlideShowListener mListener;
	private Activity mActivity;

	public SlideShowActionDialog(Activity context, SlideShow item,
			DeleteSlideShowListener listener) {
		super(context);
		mSlideShow = item;
		mActivity = context;
		mListener = listener;
	}

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.slideshow_action_dialog);
		this.getWindow().setBackgroundDrawable(
				new ColorDrawable(android.graphics.Color.TRANSPARENT));
		setCancelable(false);
		findViewById(R.id.btn_cancel).setOnClickListener(this);
		findViewById(R.id.layout_selection_open).setOnClickListener(this);
		findViewById(R.id.layout_selection_sendmail).setOnClickListener(this);
		findViewById(R.id.layout_selection_sharefb).setOnClickListener(this);
		findViewById(R.id.layout_selection_delete).setOnClickListener(this);
	}

	@Override
	public void onClick(View v) {
		String tripName = (String) TravelPrefs.getData(getContext(),
				TravelPrefs.PREF_TRIP_NAME);
		switch (v.getId()) {
		case R.id.btn_cancel:
			dismiss();
			break;
		case R.id.layout_selection_open:
			Intent videoIntent = new Intent(Intent.ACTION_VIEW);
			videoIntent
					.setDataAndType(
							Uri.fromFile(new File(mSlideShow.getFilePath())),
							"video/*");
			mActivity.startActivity(
					Intent.createChooser(videoIntent, "View SlideShow"));
			dismiss();
			break;
		case R.id.layout_selection_delete:
			new SlideShowTableAdapter(getContext()).deleteSlideShow(mSlideShow
					.getId());
			if (mListener != null) {
				mListener.onDelete(mSlideShow);
			}
			dismiss();
			break;

		case R.id.layout_selection_sharefb:
			NMShareMessage message = new NMShareMessage();
			message.setMessage(" ");
			message.setType(NMShareType.NMShareTypeStory);
			message.setPicture(mSlideShow.getThumbnail());
			message.setName(getContext().getString(R.string.subject_slideshow,
					tripName));
			message.setCaption("Created with the Travel Buddy app");
			message.setDescription(getContext().getString(
					R.string.description_slideshow_fb, tripName));
			message.setLink(mSlideShow.getServerPath());
			NMShareKit shareKit = NMShareKit
					.sharedInstance(mActivity);
			shareKit.shareFB(message);
			dismiss();
			break;
		case R.id.layout_selection_sendmail:
			Intent emailIntent = new Intent(android.content.Intent.ACTION_SEND);
			emailIntent.setType("text/html");
			emailIntent.putExtra(android.content.Intent.EXTRA_SUBJECT,
					getContext()
							.getString(R.string.subject_slideshow, tripName));
			emailIntent.putExtra(
					android.content.Intent.EXTRA_TEXT,
					Html.fromHtml(getContext().getString(R.string.content_slideshow_link,
							tripName, mSlideShow.getServerPath(), mSlideShow.getServerPath())));
//			emailIntent.putExtra(Intent.EXTRA_STREAM,
//					Uri.fromFile(new File(mSlideShow.getFilePath())));
			mActivity.startActivity(
					Intent.createChooser(emailIntent, "Send your slideshow"));
			dismiss();
			break;
		default:
			break;
		}
	}

	public interface DeleteSlideShowListener {
		void onDelete(SlideShow slideShow);
	}
}
