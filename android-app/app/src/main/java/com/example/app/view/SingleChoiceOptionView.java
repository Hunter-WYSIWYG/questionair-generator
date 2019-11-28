package com.example.app.view;

import android.content.Context;
import android.view.View;
import android.widget.RadioButton;

import com.example.app.question.Option;

// view of one single choice option
class SingleChoiceOptionView extends OptionView {

	private final RadioButton radioButton;


	// constructor
	SingleChoiceOptionView(Context context, Option option, View.OnClickListener onClickListener) {
		super(context, option);
		radioButton = new RadioButton(context);
		radioButton.setOnClickListener(onClickListener);
		addButton(radioButton);
	}

	@Override
	public boolean isChecked() {
		return radioButton.isChecked();
	}

	@Override
	public void setChecked(boolean checked) {
		radioButton.setChecked(checked);
	}
}
