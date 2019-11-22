package com.example.app.view;

import android.content.Context;
import android.support.annotation.NonNull;
import android.view.View;
import android.widget.CheckBox;

import com.example.app.question.Option;

// view of one multiple choice option
class MultipleChoiceOptionView extends OptionView {

	@NonNull
	private final CheckBox checkBox;

	// constructor
	MultipleChoiceOptionView(Context context, @NonNull Option option, View.OnClickListener onClickListener) {
		super(context, option);
		this.checkBox = new CheckBox(context);
		this.checkBox.setOnClickListener(onClickListener);
		this.addButton(this.checkBox);
	}

	@Override
	public boolean isChecked() {
		return this.checkBox.isChecked();
	}

	@Override
	public void setChecked(boolean checked) {
		this.checkBox.setChecked(checked);
	}
}
