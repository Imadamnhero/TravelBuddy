package sdc.ui.customview;

import sdc.application.TravelPrefs;
import sdc.data.Note;
import sdc.data.database.ContentProviderDB;
import sdc.data.database.adapter.NoteTableAdapter;
import sdc.travelapp.R;
import sdc.ui.fragment.NotesFragment;
import sdc.ui.travelapp.MainActivity;
import sdc.ui.utils.StringUtils;
import android.app.Dialog;
import android.content.Context;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.view.View;
import android.view.Window;
import android.widget.EditText;
import android.widget.Toast;

public class AddNoteDialog extends Dialog {
	private EditText etTitle, etContent;
	private NotesFragment mCallBack;

	public AddNoteDialog(Context context, NotesFragment callback) {
		super(context);
		this.mCallBack = callback;
	}

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.dialog_addnote);
		this.getWindow().setBackgroundDrawable(
				new ColorDrawable(android.graphics.Color.TRANSPARENT));
		setCancelable(false);
		etTitle = (EditText) findViewById(R.id.editText1);
		etContent = (EditText) findViewById(R.id.editText2);
		findViewById(R.id.btn_cancel).setOnClickListener(
				new View.OnClickListener() {
					@Override
					public void onClick(View v) {
						dismiss();
						// showConfirmDialog();
					}
				});
		findViewById(R.id.btn_right).setOnClickListener(
				new View.OnClickListener() {
					@Override
					public void onClick(View v) {
						String title = etTitle.getText().toString();
						String content = etContent.getText().toString();
						if (title.length() > 0 && content.length() > 0
								&& !StringUtils.isOnlyContainSpace(title)) {
							int userId = (Integer) TravelPrefs.getData(
									getContext(), TravelPrefs.PREF_USER_ID);
							int tripId = (Integer) TravelPrefs.getData(
									getContext(), TravelPrefs.PREF_TRIP_ID);
							Note note = new Note(-1, title, content, System
									.currentTimeMillis(), userId);
							new NoteTableAdapter(getContext()).addNote(note,
									tripId, 0, ContentProviderDB.FLAG_ADD);
							dismiss();
							mCallBack.preLoadData();
							NotesFragment.syncNoteData((MainActivity) mCallBack
									.getActivity());
						} else {
							Toast.makeText(
									getContext(),
									getContext().getString(
											R.string.toast_invalid_addnote),
									Toast.LENGTH_SHORT).show();
						}
					}
				});
	}

	protected void showConfirmDialog() {
		CustomDialog dialog = new CustomDialog(this.getContext(), this
				.getContext().getString(R.string.choose_picture_title), this
				.getContext().getString(R.string.cancel_action));
		dialog.getWindow().setBackgroundDrawable(
				new ColorDrawable(android.graphics.Color.TRANSPARENT));
		dialog.setOnClickLeft(new CustomDialog.OnClickLeft() {

			@Override
			public void click() {
				dismiss();
			}
		});
		dialog.setOnClickRight(new CustomDialog.OnClickRight() {

			@Override
			public void click() {
				dismiss();
			}
		});
		dialog.show();
		dialog.setTextBtn(this.getContext().getString(R.string.btn_yes), this
				.getContext().getString(R.string.btn_no));
	}
}
