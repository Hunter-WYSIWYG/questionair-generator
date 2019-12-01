package com.example.app.view;

import android.content.Context;
import android.support.constraint.ConstraintLayout;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.TypedValue;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.RadioButton;
import android.widget.Space;
import android.widget.TextView;

import com.example.app.QuestionDisplayActivity;
import com.example.app.R;
import com.example.app.answer.Answer;
import com.example.app.question.ChoiceQuestion;
import com.example.app.question.Option;
import com.example.app.question.OptionType;
import com.example.app.question.Question;
import com.example.app.question.QuestionType;

import java.util.ArrayList;
import java.util.List;

// TODO: allow clicking on the text next to the radio button or checkbox
// OptionView is the view of one option (button + text)
abstract class OptionView {
	// rootView of button, textView, ...
	private final LinearLayout container;
	// view of optionText
	private final TextView optionTextView;
	// option
	private final Option option;
	// edit text is null if there is no edit text
	private final EditText editText;
	
	// constructor
	protected OptionView (Context context, Option option) {
		container = (LinearLayout) View.inflate(context, R.layout.multiple_choice_option_view, null);
		optionTextView = new TextView(context);
		optionTextView.setText(option.getOptionText());
		optionTextView.setTextSize(TypedValue.COMPLEX_UNIT_SP, 24);
		this.option = option;
		editText = createEditText(context);
	}
	
	private EditText createEditText (Context context) {
		if (option.getType() == OptionType.EnterText) {
			EditText editText = new EditText (context);
			editText.setHint ("Hier eingeben...");
			return editText;
		} else if (option.getType() == OptionType.StaticText)
			return null;
		else
			throw new IllegalArgumentException ();
	}
	
	// getter
	public LinearLayout getContainer () {
		return container;
	}
	
	public Option getOption () {
		return option;
	}
	
	public EditText getEditText () {
		return editText;
	}
	
	// add button and everything else in the right order to the rootView
	protected void addButton (Button button) {
		container.addView(button);
		container.addView(optionTextView);
		if (editText != null) {
			container.addView(editText);
		}
	}
	
	// true if button is checked
	public abstract boolean isChecked ();
	
	public abstract void setChecked (boolean checked);
	
	// creates new option view depending on the question type
	public static OptionView create (Context context, Option option, Question question, View.OnClickListener onClickListener) {
		if (question.type == QuestionType.SingleChoice)
			return new SingleChoiceOptionView (context, option, onClickListener);
		else if (question.type == QuestionType.MultipleChoice)
			return new MultipleChoiceOptionView (context, option, onClickListener);
		else
			throw new IllegalArgumentException ();
	}
}

// view of one single choice option
class SingleChoiceOptionView extends OptionView {
	
	private final RadioButton radioButton;
	
	
	// constructor
	public SingleChoiceOptionView (Context context, Option option, View.OnClickListener onClickListener) {
		super (context, option);
		radioButton = new RadioButton(context);
		radioButton.setOnClickListener(onClickListener);
		addButton(radioButton);
	}
	
	@Override
	public boolean isChecked () {
		return radioButton.isChecked();
	}
	
	@Override
	public void setChecked (boolean checked) {
		radioButton.setChecked(checked);
	}
}

// view of one multiple choice option
class MultipleChoiceOptionView extends OptionView {
	
	private final CheckBox checkBox;
	
	// constructor
	public MultipleChoiceOptionView (Context context, Option option, View.OnClickListener onClickListener) {
		super (context, option);
		checkBox = new CheckBox(context);
		checkBox.setOnClickListener(onClickListener);
		addButton(checkBox);
	}
	
	@Override
	public boolean isChecked () {
		return checkBox.isChecked();
	}
	
	@Override
	public void setChecked (boolean checked) {
		checkBox.setChecked(checked);
	}
}

// TODO: suppress virtual keyboard if displaying an edit text
// TODO: select button by clicking on option text or text box and not just the button


public class MultipleChoiceView extends QuestionDisplayView {
	
	// the corresponding question
	private final ChoiceQuestion question;
	// root node of the multiple choice view
	private ConstraintLayout rootView;
	// view containing the option views
	private LinearLayout optionContainer;
	// list of all button views
	private List<OptionView> optionViews = new ArrayList<> ();
	
	// constructor
	public MultipleChoiceView (QuestionDisplayActivity activity, ChoiceQuestion question) {
		super (activity);
		this.question = question;
		init();
	}
	
	
	private void init () {
		this.rootView = (ConstraintLayout) View.inflate (this.getActivity (), R.layout.multiple_choice_view, null);
		this.optionContainer = this.rootView.findViewById (R.id.MultipleChoiceOptionContainer);
		
		// set questionTypeText
		TextView questionTypeTextView = this.rootView.findViewById (R.id.MultipleChoiceQuestionTypeText);
		questionTypeTextView.setText (this.question.type.name ());
		
		// set question Number
		TextView questionNumber = this.rootView.findViewById (R.id.questionNumber);
		questionNumber.setText("Fragenummer: " + question.questionID);
		
		// set questionText
		TextView questionTextView = this.rootView.findViewById (R.id.MultipleChoiceQuestionText);
		questionTextView.setText (this.question.questionText);
		
		// find dividingLine
		View dividingLine = this.rootView.findViewById (R.id.MultipleChoiceDividingLine);
		
		// create buttons
		createOptions();
	}
	
	// create option views
	private void createOptions () {
		for (int i = 0; i < question.options.size(); ++i) {
			// space between options
			if (i >= 0) {
				Space space = new Space(getActivity());
				space.setLayoutParams (new ViewGroup.LayoutParams (0, 30));
				optionContainer.addView(space);
			}
			
			Option option = this.question.options.get (i);
			final int finalI = i;
			OptionView view = OptionView.create(getActivity(), option, question, v -> buttonClicked(optionViews.get(finalI)));
			optionContainer.addView(view.getContainer());
			optionViews.add(view);
			
			// check if option is edit text and add listener
			if (view.getEditText () != null) {
				view.getEditText ().addTextChangedListener (new TextWatcher () {
					@Override
					public void beforeTextChanged (final CharSequence s, final int start, final int count, final int after) {
					}
					
					@Override
					public void onTextChanged (final CharSequence s, final int start, final int before, final int count) {
					}
					
					@Override
					public void afterTextChanged (final Editable s) {
						updateNextButtonEnabled();
					}
				});
			}
			
		}
	}
	
	// enable or disable 'next' button depending on whether any button is checked
	// also disable other radio buttons if this is that kind of question
	private void buttonClicked (OptionView view) {
		if (question.isSingleChoice()) {
			for (OptionView otherView : optionViews)
				if (otherView != view)
					otherView.setChecked (false);
		}
		updateNextButtonEnabled();
	}
	
	// enable or disable 'next' button depending on whether any button is checked
	private void updateNextButtonEnabled () {
		boolean enabled = nextButtonAllowed();
		getActivity().setNextButtonEnabled(enabled);
	}
	
	// true if next button should be enabled
	private boolean nextButtonAllowed () {
		return areAllCheckedValid() && isAnyButtonChecked();
	}
	
	// true if any button is checked
	private boolean isAnyButtonChecked () {
		for (OptionView optionView : optionViews) {
			if (optionView.isChecked ()) {
				return true;
			}
		}
		return false;
	}
	
	// true if all checked edit texts are not empty
	private boolean areAllCheckedValid () {
		for (OptionView optionView : optionViews) {
			if (optionView.isChecked ()) {
				if (optionView.getOption ().getType () == OptionType.EnterText) {
					Editable debug1 = optionView.getEditText ().getText ();
					String debug2 = debug1.toString ();
					
					if ("".equals(optionView.getEditText().getText().toString()))
						return false;
				}
			}
		}
		return true;
	}
	
	// implementation of abstract method from QuestionDisplayView
	@Override
	public View getView () {
		return rootView;
	}
	
	@Override
	public List<Answer> getCurrentAnswer () {
		List<Answer> returnList = new ArrayList<> ();
		for (OptionView optionView : this.optionViews) {
			if (optionView.isChecked ()) {
				returnList.add(new Answer(this.question.questionID, optionView.getOption ().getId ()));
			}
		}
		
		return returnList;
	}
	
	
}

