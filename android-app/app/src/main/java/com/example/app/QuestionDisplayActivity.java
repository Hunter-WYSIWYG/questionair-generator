package com.example.app;

import android.app.ActionBar;
import android.app.Activity;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.Point;
import android.os.Bundle;
import android.support.constraint.ConstraintLayout;
import android.support.constraint.ConstraintSet;
import android.support.v7.app.AppCompatActivity;
import android.util.TypedValue;
import android.view.Menu;
import android.view.View;
import android.view.ViewGroup;
import android.widget.*;
import com.example.app.answer.Answer;
import com.example.app.question.Option;
import com.example.app.question.Question;
import com.example.app.question.QuestionType;
import com.example.app.view.QuestionDisplayView;

import java.util.ArrayList;
import java.util.List;

public class QuestionDisplayActivity extends AppCompatActivity {
	
	// xml is divided into the questionViewContainer, the questionView inside the container and the "next" button
	private LinearLayout questionViewContainer;
	private QuestionDisplayView questionView;
	private Button nextButton;

	private QuestionnaireState state;
	
	// getter
	public QuestionnaireState getState () {
		return this.state;
	}
	
	// displays the current question of the questionnaire state
	public static void displayCurrentQuestion (QuestionnaireState questionnaireState, Activity activity) {
		Intent intent = new Intent(activity, QuestionDisplayActivity.class);
		intent.putExtra("state", questionnaireState);
		activity.startActivity(intent); // starting our own activity (onCreate) with questionnaire state so we can save it
		activity.finish(); // prevent the back button
		// TODO: if back button pressed -> popup with "sind sie sicher dass sie den fragebogen abbrechen wollen?"
	}
	
	// is called when this activity is started
	@Override
	protected void onCreate (Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		this.setContentView(R.layout.activity_question_display);
		
		this.state = (QuestionnaireState) this.getIntent().getSerializableExtra("state");
		this.questionViewContainer = this.findViewById(R.id.questionDisplayContent);
		this.nextButton = this.findViewById(R.id.questionDisplayNextButton);
		
		this.nextButton.setOnClickListener(v -> this.nextButtonClicked());
	}
	
	
	// set next button to enabled or disabled
	public void setNextButtonEnabled (boolean enabled) {
		this.nextButton.setEnabled(enabled);
		// TODO: (?) change colour of next button depending on enabled value
	}
	// next button is clicked, update questionnaire state and go to next question
	private void nextButtonClicked () {
		Answer answer = this.questionView.getCurrentAnswer();
		this.state.currentQuestionAnswered(answer);
		displayCurrentQuestion(this.state, this);
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	/*generate class wide parameters*/
	private static final int HASH_MULTIPLIER_CONSTANT = 31;
	private static final float BUTTON_HORIZONTAL_BIAS = 0.05f;
	private static final int TEXT_MARGINS = 16;
	private static final int BUTTON_LEFT_RIGHT_MARGIN = 8;
	private static final int BUTTON_TOP_BOTTOM_MARGIN = 0;
	private static final int CONTAINER_VERTICAL_MARGIN = 32;
	private static final int CONTAINER_HORIZONTAL_MARGIN = 8;
	private static final int NEXT_BUTTON_PIXEL_SIZE = 200;
	private static final float OPTION_TEXT_SIZE = 20;
	private static final int OPTION_TEXT_COLOR = Color.parseColor("#080808");
	
	/*initialize question data*/
	private int current = -1;
	private int size = -1;
	private List<Question> qList = null;
	private List<Answer> aList = null;
	private ConstraintLayout constraintLayout = null;
	private ConstraintSet constraintSet = null;
	
	/*initialize current question data*/
	private Question currentQ = null;
	private int amountOptions = -1;
	private List<Integer> containerIDs = null;
	private List<Button> optionButtons = null;
	private List<Boolean> pressedButtons = null;
	private List<TextView> optionTexts = null;
	
	@Override
	protected void onCreateOld(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_question_display);
		
		
		/* get screen dimensions */
		
		Point sSize = new Point();
		getWindowManager().getDefaultDisplay().getSize(sSize);
		final int screenWidth = sSize.x;
		final int screenHeight = sSize.y;
		
		
		/* create Layout */
		
		constraintLayout = findViewById(R.id.MultipleChoiceLayout);
		constraintSet = new ConstraintSet();
		constraintSet.clone(constraintSet);
		
		
		/* get question definition */
		
		Bundle extras = getIntent().getExtras();
		assert extras != null;
		current = extras.getInt("current", -1);
		size = extras.getInt("size", 0);
		qList = new ArrayList<>(size);
		aList = new ArrayList<>(size);
		for (int i = 0; i < size; i++) {
			qList.add((Question) extras.getSerializable("q" + i));
			aList.add((Answer) extras.getSerializable("a" + i));
		}
		
		
		/* show Status (DEBUG) */
		
		Toast toast = Toast.makeText(this, "result: " + current + ", " + qList.size() + ", " + qList.get(current).getType(), Toast.LENGTH_SHORT);
		toast.show();
		
		
		/* process next Question */
		
		currentQ = qList.get(current);
		/* set Layout */
		TextView qt = findViewById(R.id.MultipleChoiceQuestionText);
		qt.setText(currentQ.getTitle());
		qt.requestLayout();//redraw with new text
		/* process Answers */
		
		List<Option> options = currentQ.getOptionList();
		amountOptions = options.size();
		optionButtons = new ArrayList<>(amountOptions);//all Buttons
		pressedButtons = new ArrayList<>(amountOptions);//Boolean if pressed
		for (int i = 0; i < amountOptions; i++) {
			pressedButtons.add(false);
		}
		optionTexts = new ArrayList<>(amountOptions);
		TextView questionTypeTV = findViewById(R.id.MultipleChoiceQuestionTypeText);
		
		final int buttonPixelSize = Math.max(Math.min(screenHeight, screenWidth) >> 4, 32);
		containerIDs = new ArrayList<>(amountOptions);
		/*give command for layout computing and add views*/
		switch (currentQ.getType()) {
			case SingleChoice:
				questionTypeTV.setText(getString(R.string.QUESTION_TYPE_HINT_SINGLE_CHOICE));
				for (int i = 0; i < amountOptions; i++) {
					
					final ConstraintLayout container = getButtonTextBoundingLayout(buttonPixelSize, i, options.get(i), QuestionType.SingleChoice);
					final int containerID = container.getId();
					
					if (i == 0) {
						constraintSet.connect(containerID, ConstraintSet.TOP, R.id.MultipleChoiceDividingLine, ConstraintSet.BOTTOM, CONTAINER_VERTICAL_MARGIN);
					} else {
						constraintSet.connect(containerID, ConstraintSet.TOP, containerIDs.get(i - 1), ConstraintSet.BOTTOM, CONTAINER_VERTICAL_MARGIN);
					}
					containerIDs.add(containerID);
					constraintSet.connect(containerID, ConstraintSet.LEFT, R.id.MultipleChoiceLayout, ConstraintSet.LEFT, CONTAINER_HORIZONTAL_MARGIN);
					constraintSet.connect(containerID, ConstraintSet.RIGHT, R.id.MultipleChoiceLayout, ConstraintSet.RIGHT, CONTAINER_HORIZONTAL_MARGIN);
					
					constraintLayout.addView(container);
				}
				break;
			case MultipleChoice:
				questionTypeTV.setText(getString(R.string.QUESTION_TYPE_HINT_MULTIPLE_CHOICE));
				for (int i = 0; i < amountOptions; i++) {
					
					final ConstraintLayout container = getButtonTextBoundingLayout(buttonPixelSize, i, options.get(i), QuestionType.MultipleChoice);
					final int containerID = container.getId();
					
					if (i == 0) {
						constraintSet.connect(containerID, ConstraintSet.TOP, R.id.MultipleChoiceDividingLine, ConstraintSet.BOTTOM, CONTAINER_VERTICAL_MARGIN);
					} else {
						constraintSet.connect(containerID, ConstraintSet.TOP, containerIDs.get(i - 1), ConstraintSet.BOTTOM, CONTAINER_VERTICAL_MARGIN);
					}
					containerIDs.add(containerID);
					constraintSet.connect(containerID, ConstraintSet.LEFT, R.id.MultipleChoiceLayout, ConstraintSet.LEFT, CONTAINER_HORIZONTAL_MARGIN);
					constraintSet.connect(containerID, ConstraintSet.RIGHT, R.id.MultipleChoiceLayout, ConstraintSet.RIGHT, CONTAINER_HORIZONTAL_MARGIN);
					
					constraintLayout.addView(container);
				}
				break;
			case Slider:
				//TODO
				break;
		}
		
		/* create 'next' Button */
		
		Button nextButton = new Button(this);
		nextButton.setText(getString(R.string.next_button_text));
		int nbID = "nextButton".hashCode();
		nextButton.setId(nbID);
		nextButton.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(final View v) {
				nextClick();
			}
		});
		constraintLayout.addView(nextButton);
		constraintSet.connect(nbID, ConstraintSet.TOP, containerIDs.get(containerIDs.size() - 1), ConstraintSet.BOTTOM, 8);
		constraintSet.connect(nbID, ConstraintSet.RIGHT, R.id.MultipleChoiceLayout, ConstraintSet.RIGHT, 8);
		constraintSet.connect(nbID, ConstraintSet.BOTTOM, R.id.MultipleChoiceLayout, ConstraintSet.BOTTOM, 8);
		constraintSet.connect(nbID, ConstraintSet.LEFT, R.id.MultipleChoiceLayout, ConstraintSet.LEFT, screenWidth >> 1);
		constraintSet.constrainHeight(nbID, NEXT_BUTTON_PIXEL_SIZE);
		constraintSet.constrainWidth(nbID, NEXT_BUTTON_PIXEL_SIZE);
		
		constraintSet.applyTo(constraintLayout);
		//constraintLayout.setConstraintSet(constraintSet);
	}
	/*distribute content generator and create basic layout data*/
	private ConstraintLayout getButtonTextBoundingLayout(final int buttonPixelSize, final int buttonID, final Option option, final QuestionType qType) {
		if (option == null || qType == null || optionButtons == null) {
			throw new NullPointerException("tried to create container for button/text(/slider), but some argument was null, or optionButtons was null");
		}
		final String optionAnswerText = option.getAnswerText();
		
		final ConstraintLayout container = new ConstraintLayout(this);
		final int containerID = HASH_MULTIPLIER_CONSTANT * option.hashCode() + buttonID;
		container.setId(containerID);
		
		switch (qType) {
			case SingleChoice:
				switch (option.getType()) {
					case StaticText:
						addContentsSingleStatic(container, optionAnswerText, buttonID, buttonPixelSize);
						break;
					case EnterText:
						addContentsSingleEnter(container, optionAnswerText, buttonID, buttonPixelSize);
						break;
					case Slider:
						//TODO: slider
						throw new IllegalStateException("was slider");
				}
				break;
			case MultipleChoice:
				switch (option.getType()) {
					case StaticText:
						addContentsMultipleStatic(container, optionAnswerText, buttonID, buttonPixelSize);
						break;
					case EnterText:
						addContentsMultipleEnter(container, optionAnswerText, buttonID, buttonPixelSize);
						break;
					case Slider:
						//TODO: slider
						throw new IllegalStateException("was slider");
				}
				break;
			case Slider:
				//TODO:
				throw new IllegalStateException("was slider");
		}
		
		container.setLayoutParams(new ConstraintLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT));
		constraintSet.constrainMinHeight(containerID, ConstraintSet.WRAP_CONTENT);
		constraintSet.constrainHeight(containerID, ConstraintSet.WRAP_CONTENT);
		constraintSet.constrainMaxHeight(containerID, ConstraintSet.WRAP_CONTENT);
		constraintSet.constrainMinWidth(containerID, ConstraintSet.MATCH_CONSTRAINT);
		constraintSet.constrainWidth(containerID, ConstraintSet.MATCH_CONSTRAINT);
		constraintSet.constrainMaxWidth(containerID, ConstraintSet.MATCH_CONSTRAINT);
		constraintSet.applyTo(container);
		
		return container;
	}
	
	/*add a static text to multiple answer question*/
	private void addContentsSingleStatic(final ConstraintLayout container, final String answerText, final int buttonOptionID, final int buttonPixelSize) {
		assert container != null && answerText != null;
		
		final int containerID = container.getId();
		final RadioButton button = new RadioButton(this);
		button.setChecked(false);
		final TextView text = new TextView(this);
		
		button.setOnClickListener(new View.OnClickListener() {
			final int buttonInd = buttonOptionID;
			
			@Override
			public void onClick(final View v) {
				optionClickHandlerSingle(buttonInd);
			}
		});
		/*set id's and add objects to list*/
		optionButtons.add(button);
		optionTexts.add(text);
		final int buttonViewID = ("But" + buttonOptionID + "ton").hashCode();
		button.setId(buttonViewID);
		final int textID = ("Text" + buttonOptionID + "View").hashCode();
		text.setId(textID);
		button.setText("");
		setTextFont(text);
		text.setText(answerText);
		/*set size parameters*/
		button.setLayoutParams(new ConstraintLayout.LayoutParams(buttonPixelSize, buttonPixelSize));
		button.setMaxHeight(buttonPixelSize);
		button.setMaxWidth(buttonPixelSize);
		button.setMinHeight(buttonPixelSize);
		button.setMinWidth(buttonPixelSize);
		text.setLayoutParams(new ConstraintLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT));
		button.requestLayout();
		text.requestLayout();
		
		container.addView(button);
		container.addView(text);
		
		setConstraints(containerID, buttonViewID, textID, buttonPixelSize);
	}
	
	/*set constraints and base layout automatically for a button/text combo */
	private void setConstraints(final int containerID, final int buttonID, final int textID, final int buttonPixelSize) {
		constraintSet.connect(buttonID, ConstraintSet.LEFT, containerID, ConstraintSet.LEFT, BUTTON_LEFT_RIGHT_MARGIN);
		constraintSet.connect(buttonID, ConstraintSet.RIGHT, containerID, ConstraintSet.RIGHT, BUTTON_LEFT_RIGHT_MARGIN);
		constraintSet.connect(buttonID, ConstraintSet.TOP, textID, ConstraintSet.TOP, BUTTON_TOP_BOTTOM_MARGIN);
		constraintSet.connect(buttonID, ConstraintSet.BOTTOM, textID, ConstraintSet.BOTTOM, BUTTON_TOP_BOTTOM_MARGIN);
		constraintSet.setHorizontalBias(buttonID, BUTTON_HORIZONTAL_BIAS);
		constraintSet.constrainMinHeight(buttonID, buttonID);
		//noinspection PointlessArithmeticExpression
		constraintSet.constrainHeight(buttonID, buttonPixelSize + 2 * BUTTON_TOP_BOTTOM_MARGIN);
		//noinspection PointlessArithmeticExpression
		constraintSet.constrainMaxHeight(buttonID, buttonPixelSize + 2 * BUTTON_TOP_BOTTOM_MARGIN);
		constraintSet.constrainMinWidth(buttonID, buttonPixelSize);
		constraintSet.constrainWidth(buttonID, buttonPixelSize + 2 * BUTTON_LEFT_RIGHT_MARGIN);
		constraintSet.constrainMaxWidth(buttonID, buttonPixelSize + 2 * BUTTON_LEFT_RIGHT_MARGIN);
		constraintSet.setVisibility(buttonID, ConstraintSet.VISIBLE);
		
		constraintSet.connect(textID, ConstraintSet.LEFT, buttonID, ConstraintSet.RIGHT, TEXT_MARGINS);
		constraintSet.connect(textID, ConstraintSet.RIGHT, containerID, ConstraintSet.RIGHT, TEXT_MARGINS);
		constraintSet.connect(textID, ConstraintSet.TOP, containerID, ConstraintSet.TOP, TEXT_MARGINS);
		constraintSet.connect(textID, ConstraintSet.BOTTOM, containerID, ConstraintSet.BOTTOM, TEXT_MARGINS);
		constraintSet.constrainMinHeight(textID, ConstraintSet.WRAP_CONTENT);
		constraintSet.constrainHeight(textID, ConstraintSet.WRAP_CONTENT);
		constraintSet.constrainMaxHeight(textID, ConstraintSet.WRAP_CONTENT);
		constraintSet.constrainMinWidth(textID, ConstraintSet.MATCH_CONSTRAINT);
		constraintSet.constrainWidth(textID, ConstraintSet.MATCH_CONSTRAINT);
		constraintSet.constrainMaxWidth(textID, ConstraintSet.MATCH_CONSTRAINT);
		constraintSet.setVisibility(textID, ConstraintSet.VISIBLE);
	}
	
	/*change text fonts*/
	private void setTextFont(final TextView text) {
		assert text != null;
		
		text.setTextSize(TypedValue.COMPLEX_UNIT_SP, OPTION_TEXT_SIZE);
		text.setTextColor(OPTION_TEXT_COLOR);
	}
	
	/*color next button and handle clicks on single answers*/
	void optionClickHandlerSingle(int pressedButton) {
		for (int i = 0; i < amountOptions; i++) {
			if (i == pressedButton) {
				pressedButtons.set(i, true);
				Checkable rButton = (Checkable) optionButtons.get(i);
				rButton.setChecked(true);
				constraintLayout.findViewById("nextButton".hashCode()).setBackgroundColor(Color.parseColor("#8b1212")); //TODO:make void function and generate nicer look
			} else {
				pressedButtons.set(i, false);
				Checkable rButton = (Checkable) optionButtons.get(i);
				rButton.setChecked(false);
			}
		}
	}
	/*add an entertext to single answer question*/
	private void addContentsSingleEnter(final ConstraintLayout container, final String answerText, final int buttonOptionID, final int buttonPixelSize) {
		assert container != null;
		String hint = answerText;
		if (answerText == null) {
			hint = getString(R.string.DEFAULT_ENTER_TEXT_HINT);
		}
		
		final int containerID = container.getId();
		final RadioButton button = new RadioButton(this);
		button.setChecked(false);
		final EditText text = new EditText(this);
		
		button.setOnClickListener(new View.OnClickListener() {
			final int buttonInd = buttonOptionID;
			
			@Override
			public void onClick(final View v) {
				optionClickHandlerSingle(buttonInd);
			}
		});
		/*set id's and add objects to list*/
		optionButtons.add(button);
		optionTexts.add(text);
		final int buttonViewID = ("But" + buttonOptionID + "ton").hashCode();
		button.setId(buttonViewID);
		final int textID = ("Text" + buttonOptionID + "View").hashCode();
		text.setId(textID);
		button.setText("");
		setTextFont(text);
		text.setHint(hint);
		/*set size parameters*/
		button.setLayoutParams(new ConstraintLayout.LayoutParams(buttonPixelSize, buttonPixelSize));
		button.setMaxHeight(buttonPixelSize);
		button.setMaxWidth(buttonPixelSize);
		button.setMinHeight(buttonPixelSize);
		button.setMinWidth(buttonPixelSize);
		text.setMinLines(1);
		text.setLayoutParams(new ConstraintLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT));
		button.requestLayout();
		text.requestLayout();
		
		container.addView(button);
		container.addView(text);
		
		setConstraints(containerID, buttonViewID, textID, buttonPixelSize);
	}
	
	/*add a static text to multiple answer question*/
	private void addContentsMultipleStatic(final ConstraintLayout container, final CharSequence answerText, final int buttonOptionID, final int buttonPixelSize) {
		assert container != null && answerText != null;
		
		final int containerID = container.getId();
		final CheckBox button = new CheckBox(this);
		button.setChecked(false);
		final TextView text = new TextView(this);
		
		button.setOnClickListener(new View.OnClickListener() {
			final int buttonInd = buttonOptionID;
			
			@Override
			public void onClick(final View v) {
				optionClickHandlerMultiple(buttonInd);
			}
		});
		/*set id's and add objects to list*/
		optionButtons.add(button);
		optionTexts.add(text);
		final int buttonViewID = ("But" + buttonOptionID + "ton").hashCode();
		button.setId(buttonViewID);
		final int textID = ("Text" + buttonOptionID + "View").hashCode();
		text.setId(textID);
		button.setText("");
		setTextFont(text);
		text.setText(answerText);
		
		/*set size parameters*/
		button.setLayoutParams(new ConstraintLayout.LayoutParams(buttonPixelSize, buttonPixelSize));
		button.setMaxHeight(buttonPixelSize);
		button.setMaxWidth(buttonPixelSize);
		button.setMinHeight(buttonPixelSize);
		button.setMinWidth(buttonPixelSize);
		text.setLayoutParams(new ConstraintLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT));
		
		container.addView(button);
		container.addView(text);
		
		setConstraints(containerID, buttonViewID, textID, buttonPixelSize);
	}
	
	/*color next button and handle clicks on multiple answers*/
	void optionClickHandlerMultiple(int pressedButton) {
		constraintLayout.findViewById("nextButton".hashCode()).setBackgroundColor(Color.parseColor("#8b1212")); //TODO:make void function and generate nicer look
		for (int i = 0; i < amountOptions; i++) {
			if (i == pressedButton) {
				pressedButtons.set(i, !pressedButtons.get(i));
			}
		}
	}
	
	/*add an edittext to multiple answer question*/
	private void addContentsMultipleEnter(final ConstraintLayout container, final String answerText, final int buttonOptionID, final int buttonPixelSize) {
		assert container != null;
		String hint = answerText;
		if (answerText == null) {
			hint = getString(R.string.DEFAULT_ENTER_TEXT_HINT);
		}
		
		final int containerID = container.getId();
		final CheckBox button = new CheckBox(this);
		button.setChecked(false);
		final EditText text = new EditText(this);
		
		button.setOnClickListener(new View.OnClickListener() {
			final int buttonInd = buttonOptionID;
			
			@Override
			public void onClick(final View v) {
				optionClickHandlerMultiple(buttonInd);
			}
		});
		/*set id's and add objects to list*/
		optionButtons.add(button);
		optionTexts.add(text);
		final int buttonViewID = ("But" + buttonOptionID + "ton").hashCode();
		button.setId(buttonViewID);
		final int textID = ("Text" + buttonOptionID + "View").hashCode();
		text.setId(textID);
		button.setText("");
		setTextFont(text);
		text.setHint(hint);
		/*set size parameters*/
		button.setLayoutParams(new ConstraintLayout.LayoutParams(buttonPixelSize, buttonPixelSize));
		button.setMaxHeight(buttonPixelSize);
		button.setMaxWidth(buttonPixelSize);
		button.setMinHeight(buttonPixelSize);
		button.setMinWidth(buttonPixelSize);
		text.setMinLines(1);
		text.setLayoutParams(new ConstraintLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT));
		
		container.addView(button);
		container.addView(text);
		
		setConstraints(containerID, buttonViewID, textID, buttonPixelSize);
	}
	
	/* handle next click */
	public void nextClick() {
		if (noneClicked() || selectedEditTextButNoText()) {
			//no option was selected, or empty edit field selected, cannot go to next question
			return;
		}
		//TODO: move next question information stuff to utility class
		/*calculate missing questions and options for next question activity*/
		if (current < size - 1) {
			Intent intent = new Intent(this, QuestionDisplayActivity.class);
			intent.putExtra("size", size);
			intent.putExtra("current", current + 1);
			aList.set(current, calcAnswer());
			for (int j = 0; j < size; j++) {
				intent.putExtra("q" + j, qList.get(j));
				intent.putExtra("a" + j, aList.get(j));
			}
			startActivity(intent);
			/*calculate answer for save activity generate intent*/
		} else {
			Intent i = new Intent(this, SaveAnswersActivity.class);
			i.putExtra("size", size);
			for (int j = 0; j < size; j++) {
				if (j == current) {
					i.putExtra("a" + j, calcAnswer());
				} else {
					i.putExtra("a" + j, aList.get(j));
				}
			}
			startActivity(i);
		}
	}
	
	/*check for incomplete answer */
	private boolean noneClicked() {
		for (int i = 0; i < amountOptions; ++i) {
			if (pressedButtons.get(i)) {
				return false;
			}
		}
		return true;
	}
	
	/*check for given answer in edittext */
	private boolean selectedEditTextButNoText() {
		for (int i = 0; i < amountOptions; i++) {
			if (pressedButtons.get(i)) {
				TextView text = optionTexts.get(i);
				if (text instanceof EditText) {
					EditText eText = (EditText) text;
					if (eText.getText().toString().trim().isEmpty()) {
						Toast missingText = Toast.makeText(this, "Bitte eine Antwort eingeben!", Toast.LENGTH_SHORT);
						missingText.show();
						return true;
					}
				}
			}
		}
		return false;
	}
	
	/* prepare answer for next activity */
	private Answer calcAnswer() {
		switch (currentQ.getType()) {
			case SingleChoice:
				for (int i = 0; i < amountOptions; i++) {
					if (pressedButtons.get(i)) {
						return new Answer(QuestionType.SingleChoice, i);
					}
				}
			case MultipleChoice:
				Answer multipleChoiceAnswer = new Answer(QuestionType.MultipleChoice, -1);
				for (int i = 0; i < amountOptions; i++) {
					if (pressedButtons.get(i)) {
						multipleChoiceAnswer.AddAnswer(i);
					}
				}
				return multipleChoiceAnswer;
			case Slider:
				throw new IllegalStateException("Slider is not yet supported!");
			default:
				throw new IllegalStateException("current question did not have a valid type");
		}
	}
	
	/* remove back button action bar */
	public boolean onCreateOptionsMenu(Menu menu) {
		ActionBar actionBar = getActionBar();
		if (actionBar != null) {
			actionBar.setHomeButtonEnabled(false);      // Disable the button
			actionBar.setDisplayHomeAsUpEnabled(false); // Remove the left caret
			actionBar.setDisplayShowHomeEnabled(false); // Remove the icon
		}
		return true;
	}
	
	/* disable back button bottom */
	public void onBackPressed() {
		Toast myToast = Toast.makeText(this, "Zurück gehen ist nicht erlaubt!", Toast.LENGTH_SHORT);
		myToast.show();
	}
}
