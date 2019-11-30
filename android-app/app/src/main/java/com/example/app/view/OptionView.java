package com.example.app.view;

import android.content.Context;
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
	private static final int TEXT_SIZE = 24;
	// rootView of button, textView, ...
	private final LinearLayout container;
	// view of optionText
	private final TextView optionTextView;
	// option
	private final Option option;
	// edit text is null if there is no edit text
	private final EditText editText;

	// creates new option view depending on the question type
	public static OptionView create(Context context, Option option, Question question, View.OnClickListener onClickListener) {
		if (question.type == QuestionType.SingleChoice) {
			return new SingleChoiceOptionView(context, option, onClickListener);
		} else if (question.type == QuestionType.MultipleChoice) {
			return new MultipleChoiceOptionView(context, option, onClickListener);
		} else {
			throw new IllegalArgumentException();
		}
	}

	// constructor
	OptionView(Context context, Option option) {
		container = (LinearLayout) View.inflate(context, R.layout.multiple_choice_option_view, null);
		optionTextView = new TextView(context);
		optionTextView.setText(option.getOptionText());
		optionTextView.setTextSize(TypedValue.COMPLEX_UNIT_SP, TEXT_SIZE);
		this.option = option;
		editText = createEditText(context);
	}

	private EditText createEditText(Context context) {
		if (option.getType() == OptionType.EnterText) {
			EditText editText = new EditText(context);
			editText.setHint("Hier eingeben...");
			return editText;
		} else if (option.getType() == OptionType.StaticText) {
			return null;
		} else {
			throw new IllegalArgumentException();
		}
	}

	// getter
	LinearLayout getContainer() {
		return container;
	}

	Option getOption() {
		return option;
	}

	EditText getEditText() {
		return editText;
	}

	// add button and everything else in the right order to the rootView
	void addButton(Button button) {
		container.addView(button);
		container.addView(optionTextView);
		if (editText != null) {
			container.addView(editText);
		}
	}

	// true if button is checked
	public abstract boolean isChecked();

	public abstract void setChecked(boolean checked);
}
