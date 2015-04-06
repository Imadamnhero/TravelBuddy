package sdc.ui.customview;

import sdc.application.TravelPrefs;
import sdc.data.Category;
import sdc.data.database.adapter.CategoryTableAdapter;
import sdc.data.database.adapter.ExpenseTableAdapter;
import sdc.travelapp.R;
import android.app.Dialog;
import android.content.Context;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.view.View;
import android.view.Window;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

public class EditCategoriesDialog extends Dialog {
	private EditText etTitle;
	private EditCategoryCallBack mCallBack;
	private Category mCategory;

	public EditCategoriesDialog(Context context, EditCategoryCallBack callback) {
		super(context);
		this.mCallBack = callback;
	}

	public EditCategoriesDialog(Context context, Category category,
			EditCategoryCallBack callback) {
		this(context, callback);
		this.mCategory = category;
	}

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.dialog_edit_category);
		this.getWindow().setBackgroundDrawable(
				new ColorDrawable(android.graphics.Color.TRANSPARENT));
		setCancelable(false);
		etTitle = (EditText) findViewById(R.id.editText1);
		View btnDelete = findViewById(R.id.btn_delete);

		if (mCategory != null) {
			etTitle.setText(mCategory.getNameCate());
			btnDelete.setVisibility(View.VISIBLE);
			btnDelete.setOnClickListener(new View.OnClickListener() {

				@Override
				public void onClick(View v) {
					showConfirmDialog();
				}
			});
			((TextView) findViewById(R.id.textView1)).setText("Edit Category");
		} else {
			btnDelete.setVisibility(View.GONE);
			((TextView) findViewById(R.id.textView1))
					.setText("Add New Category");
		}

		findViewById(R.id.btn_cancel).setOnClickListener(
				new View.OnClickListener() {
					@Override
					public void onClick(View v) {
						dismiss();
						// showConfirmDialog();
					}
				});

		findViewById(R.id.btn_save).setOnClickListener(
				new View.OnClickListener() {
					@Override
					public void onClick(View v) {
						String title = etTitle.getText().toString().trim();
						if (title.length() > 0) {
							CategoryTableAdapter categoryTableAdapter = new CategoryTableAdapter(
									getContext());
							if (!categoryTableAdapter.isNameExist(
									title,
									mCategory == null ? 0 : mCategory
											.getLocalId())) {
								if (mCategory == null) {

									mCategory = new Category(0, title);
									int userId = (Integer) TravelPrefs.getData(
											getContext(),
											TravelPrefs.PREF_USER_ID);
									int color = categoryTableAdapter
											.getNextColor(userId);
									mCategory.setUserId(userId);
									mCategory.setColor(color);
									int id = categoryTableAdapter
											.addOrUpdateCategory(mCategory,
													color, userId);
									mCategory.setLocalId(id);
									if (mCallBack != null) {
										mCallBack.onSuccess(mCategory);
									}
								} else {
									mCategory.setNameCate(title);
									categoryTableAdapter.updateTitle(
											mCategory.getLocalId(), title);
									if (mCallBack != null) {
										mCallBack.onSuccess(mCategory);
									}
								}
								dismiss();
							} else {
								Toast.makeText(
										getContext(),
										getContext().getString(
												R.string.toast_exist_addnote),
										Toast.LENGTH_SHORT).show();
							}
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
				.getContext().getString(R.string.txt_delete_category_title),
				this.getContext().getString(R.string.txt_delete_category_msg));
		dialog.getWindow().setBackgroundDrawable(
				new ColorDrawable(android.graphics.Color.TRANSPARENT));
		dialog.setOnClickLeft(new CustomDialog.OnClickLeft() {

			@Override
			public void click() {
				new CategoryTableAdapter(getContext())
						.deleteOfflineUponId(mCategory.getLocalId());
				new ExpenseTableAdapter(getContext())
						.deleteExpenseOfCategory(mCategory.getLocalId());
				if (mCallBack != null) {
					mCallBack.onDelete(mCategory);
				}
				dismiss();
			}
		});
		dialog.setOnClickRight(new CustomDialog.OnClickRight() {

			@Override
			public void click() {
			}
		});
		dialog.show();
		dialog.setTextBtn(this.getContext().getString(R.string.btn_yes), this
				.getContext().getString(R.string.btn_no));
	}

	public interface EditCategoryCallBack {
		void onSuccess(Category category);

		void onDelete(Category category);
	}
}
