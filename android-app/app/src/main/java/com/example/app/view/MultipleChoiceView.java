package com.example.app.view;

import android.content.Context;
import android.content.SharedPreferences;
import android.preference.Preference;
import android.preference.PreferenceManager;
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

import com.example.app.MainActivity;
import com.example.app.QuestionDisplayActivity;
import com.example.app.QuestionnaireState;
import com.example.app.R;
import com.example.app.answer.Answer;
import com.example.app.answer.AnswerCollection;
import com.example.app.question.ChoiceQuestion;
import com.example.app.question.Option;
import com.example.app.question.OptionType;
import com.example.app.question.Question;
import com.example.app.question.QuestionType;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;

import static com.example.app.MainActivity.username;

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

	//current State
	private final QuestionnaireState questionnaireState;
	// constructor
	protected OptionView (Context context, Option option, QuestionnaireState state) {
		this.container = (LinearLayout) View.inflate (context, R.layout.multiple_choice_option_view, null);
		this.optionTextView = new TextView (context);
		this.optionTextView.setText (option.getOptionText ());
		this.optionTextView.setTextSize (TypedValue.COMPLEX_UNIT_SP, 24);
		this.option = option;
		this.questionnaireState = state;
		this.editText = createEditText (context);
	}
	
	private EditText createEditText (Context context) {
		if (this.option.getType () == OptionType.EnterText) {
			EditText editText = new EditText (context);
			editText.setHint ("Hier eingeben...");
			return editText;
		} else if (this.option.getType () == OptionType.StaticText)
			return null;
		else
			throw new IllegalArgumentException ();
	}
	
	// getter
	public LinearLayout getContainer () {
		return this.container;
	}
	public Option getOption () {
		return this.option;
	}
	public EditText getEditText () {
		return this.editText;
	}
	
	// add button and everything else in the right order to the rootView
	protected void addButton (Button button) {
		this.container.addView (button);
		this.container.addView (this.optionTextView);
		if (this.editText != null) {
			this.container.addView (this.editText);
		}
	}
	
	// true if button is checked
	public abstract boolean isChecked ();
	
	public abstract void setChecked (boolean checked);
	
	// creates new option view depending on the question type
	public static OptionView create (Context context, Option option, Question question, View.OnClickListener onClickListener, QuestionnaireState state) {
		if (question.type == QuestionType.SingleChoice)
			return new SingleChoiceOptionView (context, option, onClickListener, state);
		else if (question.type == QuestionType.MultipleChoice)
			return new MultipleChoiceOptionView (context, option, onClickListener, state);
		else if (question.type == QuestionType.BinaryChoice)
			return new SingleChoiceOptionView (context, option, onClickListener, state);
		else
			throw new IllegalArgumentException ();
	}
}

// view of one single choice option
class SingleChoiceOptionView extends OptionView {
	
	private final RadioButton radioButton;
	
	
	// constructor
	public SingleChoiceOptionView (Context context, Option option, View.OnClickListener onClickListener, QuestionnaireState state) {
		super (context, option,state);
		this.radioButton = new RadioButton (context);
		this.radioButton.setOnClickListener (onClickListener);
		addButton (this.radioButton);
	}
	
	@Override
	public boolean isChecked () {
		return this.radioButton.isChecked ();
	}
	
	@Override
	public void setChecked (boolean checked) {
		this.radioButton.setChecked (checked);
	}
}

// view of one multiple choice option
class MultipleChoiceOptionView extends OptionView {
	
	private final CheckBox checkBox;
	
	// constructor
	public MultipleChoiceOptionView (Context context, Option option, View.OnClickListener onClickListener, QuestionnaireState state) {
		super (context, option, state);
		this.checkBox = new CheckBox (context);
		this.checkBox.setOnClickListener (onClickListener);
		addButton (this.checkBox);
	}
	
	@Override
	public boolean isChecked () {
		return this.checkBox.isChecked ();
	}
	
	@Override
	public void setChecked (boolean checked) {
		this.checkBox.setChecked (checked);
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

	private final List<OptionView> optionViews = new ArrayList<> ();
	//current State
	private final QuestionnaireState questionnaireState;

	// constructor
	public MultipleChoiceView (QuestionDisplayActivity activity, ChoiceQuestion question,QuestionnaireState state) {
		super (activity);
		this.question = question;
		this.questionnaireState = state;
		this.init ();
	}
	
	private void init () {
		this.rootView = (ConstraintLayout) View.inflate (this.getActivity (), R.layout.multiple_choice_view, null);
		this.optionContainer = this.rootView.findViewById (R.id.MultipleChoiceOptionContainer);
		

		
		// set hint
		TextView hintTextView = this.rootView.findViewById (R.id.hint);
		hintTextView.setText (this.question.hint);
		
		
		// set questionText
		TextView questionTextView = this.rootView.findViewById (R.id.MultipleChoiceQuestionText);
		questionTextView.setText (this.question.questionText);
		
		// find dividingLine
		View dividingLine = this.rootView.findViewById (R.id.MultipleChoiceDividingLine);
		
		// create buttons
		this.createOptions();
	}
	
	// create option views
	private void createOptions () {
		for (int i = 0; i < this.question.options.size (); ++i) {
			// space between options
			if (i >= 0) {
				Space space = new Space (this.getActivity ());
				space.setLayoutParams (new ViewGroup.LayoutParams (0, 30));
				this.optionContainer.addView (space);
			}
			
			Option option = this.question.options.get (i);
			final int finalI = i;
			OptionView view = OptionView.create (getActivity (), option, this.question, v -> this.buttonClicked (this.optionViews.get (finalI)), this.questionnaireState);
			this.optionContainer.addView (view.getContainer ());
			this.optionViews.add (view);
			
			// check if option is edit text and add listener
			if (view.getEditText () != null) {
				view.getEditText ().addTextChangedListener (new TextWatcher () {
					@Override
					public void beforeTextChanged (final CharSequence s, final int start, final int count, final int after) {}
					@Override
					public void onTextChanged (final CharSequence s, final int start, final int before, final int count) {}
					@Override
					public void afterTextChanged (final Editable s) {
						updateNextButtonEnabled ();
					}
				});
			}
		}
	}
	
	// enable or disable 'next' button depending on whether any button is checked
	// also disable other radio buttons if this is that kind of question
	private void buttonClicked (OptionView view) {
		if (this.question.isSingleChoice () || this.question.isBinaryChoice ()) {
			for (OptionView otherView : this.optionViews)
				if (otherView != view)
					otherView.setChecked (false);
		}
		this.updateNextButtonEnabled ();
	}
	
	// enable or disable 'next' button depending on whether any button is checked
	private void updateNextButtonEnabled () {
		boolean enabled = this.nextButtonAllowed ();
		this.getActivity ().setNextButtonEnabled (enabled);
	}
	
	// true if next button should be enabled
	private boolean nextButtonAllowed () {
		return this.areAllCheckedValid () && this.isAnyButtonChecked ();
	}
	
	// true if any button is checked
	private boolean isAnyButtonChecked () {
		for (OptionView optionView : this.optionViews) {
			if (optionView.isChecked ()) {
				return true;
			}
		}
		return false;
	}
	
	// true if all checked edit texts are not empty
	private boolean areAllCheckedValid () {
		for (OptionView optionView : this.optionViews) {
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
		return this.rootView;
	}
	
	@Override
	public AnswerCollection getCurrentAnswer() {
		Calendar calendar = Calendar.getInstance (); // gets current instance of the calendar
		if(this.question.isSingleChoice () || this.question.isBinaryChoice ()) {
			for (OptionView optionView : this.optionViews) {
				if (optionView.isChecked ()) {
					Answer answer = new Answer(this.question.type.toString (), optionView.getOption ().getId (), optionView.getOption ().getOptionText ());
					List<Answer> answerList = new ArrayList<Answer> ();
					answerList.add(answer);
					AnswerCollection answerCollection = new AnswerCollection(this.questionnaireState.getQuestionnaire ().getName (), getPreferenceValue (), calendar.getTime (), (int) (this.questionnaireState.getQuestionnaire ().getID ()), this.question.type, this.question.id, this.question.questionText, answerList);
					return answerCollection;
				}
			}
			return null;
		}
		else {
			List<Answer> answerList = new ArrayList<Answer> ();
			for (OptionView optionView : this.optionViews) {
				if (optionView.isChecked ()) {
					Answer answer = new Answer (this.question.type.toString (), optionView.getOption ().getId (), optionView.getOption ().getOptionText ());
					answerList.add (answer);
				}
			}
			AnswerCollection answerCollection = new AnswerCollection (this.questionnaireState.getQuestionnaire ().getName (), getPreferenceValue (), calendar.getTime (), (int) (this.questionnaireState.getQuestionnaire ().getID ()), this.question.type, this.question.id, this.question.questionText, answerList);
			return answerCollection;
		}
	}

	// get shared preference username
	public String getPreferenceValue ()	{
		SharedPreferences sp = this.getActivity().getSharedPreferences(username, 0);
		String str = sp.getString("key","");
		return str;
	}
}