package com.example.app.view;

import android.content.Context;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.util.TypedValue;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.example.app.R;
import com.example.app.question.Option;
import com.example.app.question.OptionType;
import com.example.app.question.Question;
import com.example.app.question.QuestionType;

// TODO: allow clicking on the text next to the radio button or checkbox
// OptionView is the view of one option (button + text)
abstract class OptionView {
	// rootView of button, textView, ...
	@NonNull
	private final LinearLayout container;
	// view of optionText
	@NonNull
	private final TextView optionTextView;
	// option
	@NonNull
	private final Option option;
	// edit text is null if there is no edit text
	@Nullable
	private final EditText editText;

	// constructor
	OptionView(Context context, @NonNull Option option) {
		this.container = (LinearLayout) View.inflate(context, R.layout.multiple_choice_option_view, null);
		this.optionTextView = new TextView(context);
		this.optionTextView.setText(option.getOptionText());
		this.optionTextView.setTextSize(TypedValue.COMPLEX_UNIT_SP, 24);
		this.option = option;
		this.editText = this.createEditText(context);
	}

	// creates new option view depending on the question type
	@NonNull
	public static OptionView create(Context context, @NonNull Option option, @NonNull Question question, View.OnClickListener onClickListener) {
		if (question.type == QuestionType.SingleChoice) {
			return new SingleChoiceOptionView(context, option, onClickListener);
		} else if (question.type == QuestionType.MultipleChoice) {
			return new MultipleChoiceOptionView(context, option, onClickListener);
		} else {
			throw new IllegalArgumentException();
		}
	}

	@Nullable
	private EditText createEditText(Context context) {
		if (this.option.getType() == OptionType.EnterText) {
			EditText editText = new EditText(context);
			editText.setHint("Hier eingeben...");
			return editText;
		} else if (this.option.getType() == OptionType.StaticText) {
			return null;
		} else {
			throw new IllegalArgumentException();
		}
	}

	// getter
	@NonNull
	LinearLayout getContainer() {
		return this.container;
	}

	@NonNull
	Option getOption() {
		return this.option;
	}

	@Nullable
	EditText getEditText() {
		return this.editText;
	}

	// add button and everything else in the right order to the rootView
	void addButton(Button button) {
		this.container.addView(button);
		this.container.addView(this.optionTextView);
		if (this.editText != null) {
			this.container.addView(this.editText);
		}
	}

	// true if button is checked
	public abstract boolean isChecked();

	public abstract void setChecked(boolean checked);
}
