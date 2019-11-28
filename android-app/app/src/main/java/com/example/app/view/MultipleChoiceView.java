package com.example.app.view;

import android.support.constraint.ConstraintLayout;
import android.text.Editable;
import android.text.TextWatcher;
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
import com.example.app.QuestionnaireState;
import com.example.app.R;
import com.example.app.answer.Answer;
import com.example.app.answer.Answers;
import com.example.app.question.ChoiceQuestion;
import com.example.app.question.Option;
import com.example.app.question.OptionType;
import com.example.app.question.Question;
import com.example.app.question.QuestionType;

import java.util.ArrayList;
import java.util.Calendar;
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
	//current State
	private final QuestionnaireState qState;
	// constructor
	protected OptionView (Context context, Option option, QuestionnaireState state) {
		container = (LinearLayout) View.inflate(context, R.layout.multiple_choice_option_view, null);
		optionTextView = new TextView(context);
		optionTextView.setText(option.getOptionText());
		optionTextView.setTextSize(TypedValue.COMPLEX_UNIT_SP, 24);
		this.option = option;
		qState=state;
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
	public static OptionView create (Context context, Option option, Question question, View.OnClickListener onClickListener, QuestionnaireState state) {
		if (question.type == QuestionType.SingleChoice)
			return new SingleChoiceOptionView (context, option, onClickListener,state);
		else if (question.type == QuestionType.MultipleChoice)
			return new MultipleChoiceOptionView (context, option, onClickListener,state);
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
	public MultipleChoiceOptionView (Context context, Option option, View.OnClickListener onClickListener, QuestionnaireState state) {
		super (context, option, state);
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
	private final List<OptionView> optionViews = new ArrayList<>();
	//current State
	private final QuestionnaireState qState;
	// constructor
	MultipleChoiceView(QuestionDisplayActivity activity, ChoiceQuestion question,QuestionnaireState state) {
		super(activity);
		this.question = question;
		qState=state;
		init();
	}
	
	
	private void init() {
		rootView = (ConstraintLayout) View.inflate(getActivity(), R.layout.multiple_choice_view, null);
		optionContainer = rootView.findViewById(R.id.MultipleChoiceOptionContainer);
		
		// set questionTypeText
		TextView questionTypeTextView = rootView.findViewById(R.id.MultipleChoiceQuestionTypeText);
		questionTypeTextView.setText(question.type.name());
		
		// set questionText
		TextView questionTextView = rootView.findViewById(R.id.MultipleChoiceQuestionText);
		questionTextView.setText(question.questionText);
		
		// find dividingLine
		View dividingLine = rootView.findViewById(R.id.MultipleChoiceDividingLine);
		
		// create buttons
		createOptions();
	}
	
	// create option views
	private void createOptions() {
		for (int i = 0; i < question.options.size(); ++i) {
			// space between options
			Space space = new Space(getActivity());
			space.setLayoutParams(new ViewGroup.LayoutParams(0, 30));
			optionContainer.addView(space);
			
			Option option = question.options.get(i);
			final int finalI = i;
			OptionView view = OptionView.create(getActivity(), option, question, v -> buttonClicked(optionViews.get(finalI)),qState);
			optionContainer.addView(view.getContainer());
			optionViews.add(view);
			
			// check if option is edit text and add listener
			if (view.getEditText() != null) {
				view.getEditText().addTextChangedListener(new TextWatcher() {
					@Override
					public void beforeTextChanged(final CharSequence s, final int start, final int count, final int after) {
					}
					
					@Override
					public void onTextChanged(final CharSequence s, final int start, final int before, final int count) {
					}
					
					@Override
					public void afterTextChanged(final Editable s) {
						updateNextButtonEnabled();
					}
				});
			}
			
		}
	}
	
	// enable or disable 'next' button depending on whether any button is checked
	// also disable other radio buttons if this is that kind of question
	private void buttonClicked(OptionView view) {
		if (question.isSingleChoice()) {
			for (OptionView otherView : optionViews)
				if (otherView != view)
					otherView.setChecked(false);
		}
		updateNextButtonEnabled();
	}
	
	// enable or disable 'next' button depending on whether any button is checked
	private void updateNextButtonEnabled() {
		boolean enabled = nextButtonAllowed();
		getActivity().setNextButtonEnabled(enabled);
	}
	
	// true if next button should be enabled
	private boolean nextButtonAllowed() {
		return areAllCheckedValid() && isAnyButtonChecked();
	}
	
	// true if any button is checked
	private boolean isAnyButtonChecked() {
		for (OptionView optionView : optionViews) {
			if (optionView.isChecked()) {
				return true;
			}
		}
		return false;
	}
	
	// true if all checked edit texts are not empty
	private boolean areAllCheckedValid() {
		for (OptionView optionView : optionViews) {
			if (optionView.isChecked()) {
				if (optionView.getOption().getType() == OptionType.EnterText) {
					assert optionView.getEditText() != null;
					if ("".equals(optionView.getEditText().getText().toString()))
						return false;
				}
			}
		}
		return true;
	}
	
	// implementation of abstract method from QuestionDisplayView
	@Override
	public View getView() {
		return rootView;
	}

	@NotNull
	private List<Integer> getIdsOfAllChecked() {
		final List<Integer> list = new ArrayList<>(question.options.size());
		for (OptionView optionView : this.optionViews) {
			if (optionView.isChecked()) {
				// -1 to account for 1-indexing of Option
				list.add(optionView.getOption().getId() - 1);
			}
		}
		return list;
	}

	@NotNull
	@Override
	public Answers getCurrentAnswer() {
		
		Calendar calendar = Calendar.getInstance(); // gets current instance of the calendar
		if(this.question.isSingleChoice()){
			for (OptionView optionView : optionViews) {
				if (optionView.isChecked ()) {
					Answer ans=new Answer(question.type.toString(),optionView.getOption().getId()  , optionView.getOption().getOptionText());
					List<Answer> answerList=new ArrayList<Answer>();
					answerList.add(ans);
					Answers answers=new Answers(qState.getQuestionnaire().getName(),calendar.getTime(),(int) (qState.getQuestionnaire().getID()),question.type,question.id,question.questionText,answerList);
					return answers;
				}
			}
			return new MultipleChoiceAnswer(question, getIdsOfAllChecked());
			
		}else{
			List<Answer> answerList=new ArrayList<Answer>();
			for (OptionView optionView : optionViews) {
				if (optionView.isChecked ()) {
					Answer ans=new Answer(question.type.toString(),optionView.getOption().getId()  , optionView.getOption().getOptionText());
					answerList.add(ans);
				}
			}
			Answers answers=new Answers(qState.getQuestionnaire().getName(),calendar.getTime(),(int) (qState.getQuestionnaire().getID()),question.type,question.id,question.questionText,answerList);
			return answers;
			
		}
		
	}
}

