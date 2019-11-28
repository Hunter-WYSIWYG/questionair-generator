package com.example.app.view;

import android.content.Context;
import android.view.View;
import android.widget.CheckBox;

import com.example.app.question.Option;

// view of one multiple choice option
class MultipleChoiceOptionView extends OptionView {

	private final CheckBox checkBox;

	// constructor
	MultipleChoiceOptionView(Context context, Option option, View.OnClickListener onClickListener) {
		super(context, option);
		checkBox = new CheckBox(context);
		checkBox.setOnClickListener(onClickListener);
		addButton(checkBox);
	}

	@Override
	public boolean isChecked() {
		return checkBox.isChecked();
	}

	@Override
	public void setChecked(boolean checked) {
		checkBox.setChecked(checked);
	}
}
