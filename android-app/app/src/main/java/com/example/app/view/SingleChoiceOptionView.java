package com.example.app.view;

import android.content.Context;
import android.support.annotation.NonNull;
import android.view.View;
import android.widget.RadioButton;

import com.example.app.question.Option;

// view of one single choice option
class SingleChoiceOptionView extends OptionView {

	@NonNull
	private final RadioButton radioButton;


	// constructor
	SingleChoiceOptionView(Context context, @NonNull Option option, View.OnClickListener onClickListener) {
		super(context, option);
		this.radioButton = new RadioButton(context);
		this.radioButton.setOnClickListener(onClickListener);
		this.addButton(this.radioButton);
	}

	@Override
	public boolean isChecked() {
		return this.radioButton.isChecked();
	}

	@Override
	public void setChecked(boolean checked) {
		this.radioButton.setChecked(checked);
	}
}
