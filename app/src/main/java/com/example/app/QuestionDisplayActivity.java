package com.example.app;

import android.app.ActionBar;
import android.content.Intent;
import android.graphics.Point;
import android.os.Bundle;
import android.support.constraint.ConstraintLayout;
import android.support.constraint.ConstraintSet;
import android.support.v7.app.AppCompatActivity;
import android.view.Menu;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.RadioButton;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

public class QuestionDisplayActivity extends AppCompatActivity {
	private static final int HASH_MULTIPLIER_CONSTANT = 31;
	private static final float BUTTON_HORIZONTAL_BIAS = 0.05f;
	private static final int TEXT_MARGINS = 16;
	private static final int BUTTON_LEFT_RIGHT_MARGIN = 8;
	private static final int BUTTON_TOP_BOTTOM_MARGIN = 0;
	private static final int CONTAINER_VERTICAL_MARGIN = 32;
	private static final int CONTAINER_HORIZONTAL_MARGIN = 8;
	private static final int NEXT_BUTTON_PIXEL_SIZE = 128;
	
	private int screenWidth = 0;
	private int screenHeight = 0;
	
	private int current = -1;
	private int size = -1;
	private List<Question> qList = null;
	private List<Answer> aList = null;
	private ConstraintLayout constraintLayout = null;
	private ConstraintSet constraintSet = null;
	
	private Question currentQ = null;
	private int amountOptions = -1;
	private List<Integer> containerIDs = null;
	private List<Button> optionButtons = null;
	private List<Boolean> pressedButtons = null;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_question_display);
		
		/* create Layout */
		
		Point sSize = new Point();
		getWindowManager().getDefaultDisplay().getSize(sSize);
		screenWidth = sSize.x;
		screenHeight = sSize.y;
		
		constraintLayout = findViewById(R.id.QuestionDisplayLayout);
		constraintSet = new ConstraintSet();
		constraintSet.clone(constraintSet);
		
		/* get extras */
		
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
		
		/* show Status */
		
		Toast toast = Toast.makeText(this, "result: " + current + ", " + qList.size() + ", " + qList.get(current).getType(), Toast.LENGTH_SHORT);
		toast.show();
		
		/* process next Question */
		
		currentQ = qList.get(current);
		/* set Layout */
		TextView qid = findViewById(R.id.QuestionID);
		qid.setText("Frage " + currentQ.getId());
		
		TextView qt = findViewById(R.id.QuestionText);
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
		TextView questiontypeTV = findViewById(R.id.qTypeText);
		
		final int buttonPixelSize = Math.max(Math.min(screenHeight, screenWidth) >> 4, 32);
		containerIDs = new ArrayList<>(amountOptions);
		
		switch (currentQ.getType()) {
			case SingleChoice:
				questiontypeTV.setText("Single-Choice-Frage");
				for (int i = 0; i < amountOptions; i++) {
					
					final ConstraintLayout container = getButtonTextBoundingLayout(buttonPixelSize, i, options.get(i), QuestionType.SingleChoice);
					final int containerID = container.getId();
					
					if (i == 0) {
						constraintSet.connect(containerID, ConstraintSet.TOP, R.id.test_layout_for_container_creation, ConstraintSet.BOTTOM, CONTAINER_VERTICAL_MARGIN);
					} else {
						constraintSet.connect(containerID, ConstraintSet.TOP, containerIDs.get(i - 1), ConstraintSet.BOTTOM, CONTAINER_VERTICAL_MARGIN);
					}
					containerIDs.add(containerID);
					constraintSet.connect(containerID, ConstraintSet.LEFT, R.id.QuestionDisplayLayout, ConstraintSet.LEFT, CONTAINER_HORIZONTAL_MARGIN);
					constraintSet.connect(containerID, ConstraintSet.RIGHT, R.id.QuestionDisplayLayout, ConstraintSet.RIGHT, CONTAINER_HORIZONTAL_MARGIN);
					
					constraintLayout.addView(container);
				}
				
				/*
				questiontypeTV.setText("Single-Choice-Frage");
				for (int i = -1; i < amountOptions; i++) {
					Option o;
					if (i >= 0) {
						o = options.get(i);
					} else {
						o = new Option(-1, "Baseline Option", OptionType.StaticText);
					}
					Button b = null;
					switch (o.getType()) {
						case StaticText:
							b = new Button(this);
							ScrollView sv = new ScrollView(this);
							TextView tv = new TextView(this);
							sv.addView(tv);
							final int index = i;
							b.setOnClickListener(new View.OnClickListener() {
								final int buttonInd = index;
								
								@Override
								public void onClick(final View v) {
									optionClickHandlerSingle(buttonInd);
								}
							});
							
							b.setText(String.format(Locale.GERMAN, "%d.", i));
							int bID = ("but" + i + "ton").hashCode();//generating a unique but knowable id
							b.setId(bID);
							constraintLayout.addView(b);
							b.setLayoutParams(new ConstraintLayout.LayoutParams(16, 16));
							if (i == -1) {
								constraintSet.connect(bID, ConstraintSet.TOP, R.id.QuestionText, ConstraintSet.BOTTOM, 8);
							} else {
								constraintSet.connect(bID, ConstraintSet.TOP, ("Text" + (i - 1) + "View").hashCode(), ConstraintSet.BOTTOM, 8);
							}
							final int marginRight = screenWidth >> 1;
							constraintSet.connect(bID, ConstraintSet.RIGHT, R.id.QuestionDisplayLayout, ConstraintSet.RIGHT, marginRight);
							final int marginBot = ((amountOptions - i) * (3 * screenHeight / 4)) / (amountOptions);
							constraintSet.connect(bID, ConstraintSet.BOTTOM, R.id.QuestionDisplayLayout, ConstraintSet.BOTTOM, marginBot);
							constraintSet.connect(bID, ConstraintSet.LEFT, R.id.QuestionDisplayLayout, ConstraintSet.LEFT, 8);
							b.requestLayout();
							tv.setText(o.getAnswerText());
							int tvID = (i == (amountOptions - 1)) ? "last".hashCode() : ("Text" + i + "View").hashCode();//generating a unique but knowable id
							sv.setId(tvID);
							constraintLayout.addView(sv);
							sv.setLayoutParams(new ConstraintLayout.LayoutParams(16, 16));
							constraintSet.connect(tvID, ConstraintSet.TOP, bID, ConstraintSet.TOP, 0);
							constraintSet.connect(tvID, ConstraintSet.RIGHT, R.id.QuestionDisplayLayout, ConstraintSet.RIGHT, 8);
							constraintSet.connect(tvID, ConstraintSet.BOTTOM, R.id.QuestionDisplayLayout, ConstraintSet.BOTTOM, marginBot);
							constraintSet.connect(tvID, ConstraintSet.LEFT, bID, ConstraintSet.RIGHT, marginRight / 16);
							sv.requestLayout();
							break;
						
						case EnterText:
							b = new Button(this);
							EditText et = new EditText(this);
							
							
							final int etindex = i;
							b.setOnClickListener(new View.OnClickListener() {
								final int buttonInd = etindex;
								
								@Override
								public void onClick(final View v) {
									optionClickHandlerSingle(buttonInd);
								}
							});
							
							b.setText(String.format(Locale.GERMAN, "%d." + o.getAnswerText(), i));
							int etbID = ("but" + i + "ton").hashCode();//generating a unique but knowable id
							b.setId(etbID);
							constraintLayout.addView(b);
							b.setLayoutParams(new ConstraintLayout.LayoutParams(16, 16));
							if (i == -1) {
								constraintSet.connect(etbID, ConstraintSet.TOP, R.id.QuestionText, ConstraintSet.BOTTOM, 8);
							} else {
								constraintSet.connect(etbID, ConstraintSet.TOP, ("Text" + (i - 1) + "View").hashCode(), ConstraintSet.BOTTOM, 8);
							}
							final int etmarginRight = screenWidth >> 1;
							constraintSet.connect(etbID, ConstraintSet.RIGHT, R.id.QuestionDisplayLayout, ConstraintSet.RIGHT, etmarginRight);
							final int etmarginBot = ((amountOptions - i) * (3 * screenHeight / 4)) / (amountOptions);
							constraintSet.connect(etbID, ConstraintSet.BOTTOM, R.id.QuestionDisplayLayout, ConstraintSet.BOTTOM, etmarginBot);
							constraintSet.connect(etbID, ConstraintSet.LEFT, R.id.QuestionDisplayLayout, ConstraintSet.LEFT, 8);
							b.requestLayout();
							
							// EditText - setHint and no setText
							et.setHint("Hier eingeben");
							int ettvID = (i == (amountOptions - 1)) ? "last".hashCode() : ("Text" + i + "View").hashCode();//generating a unique but knowable id
							et.setId(ettvID);
							constraintLayout.addView(et);
							et.setLayoutParams(new ConstraintLayout.LayoutParams(32, 16));
							constraintSet.connect(ettvID, ConstraintSet.TOP, etbID, ConstraintSet.TOP, 0);
							constraintSet.connect(ettvID, ConstraintSet.RIGHT, R.id.QuestionDisplayLayout, ConstraintSet.RIGHT, 8);
							constraintSet.connect(ettvID, ConstraintSet.BOTTOM, R.id.QuestionDisplayLayout, ConstraintSet.BOTTOM, etmarginBot);
							constraintSet.connect(ettvID, ConstraintSet.LEFT, etbID, ConstraintSet.RIGHT, etmarginRight / 16);
							et.requestLayout();
							break;
						
						case Slider:
							//TODO
							//slider up to customer at later point
							break;
					}
					optionButtons.add(b);
				}
				*/
				break;
			case MultipleChoice:
				questiontypeTV.setText("Multiple-Choice-Frage");
				for (int i = -1; i < amountOptions; i++) {
					Option o;
					if (i >= 0) {
						o = options.get(i);
					} else {
						o = new Option(-1, "Baseline Option", OptionType.StaticText);
					}
					Button b = null;
					switch (o.getType()) {
						case StaticText:
							b = new Button(this);
							ScrollView sv = new ScrollView(this);
							TextView tv = new TextView(this);
							sv.addView(tv);
							final int index = i;
							b.setOnClickListener(new View.OnClickListener() {
								final int buttonInd = index;
								
								@Override
								public void onClick(final View v) {
									optionClickHandlerMultiple(buttonInd);
								}
							});
							
							b.setText(String.format(Locale.GERMAN, "%d.", i));
							int bID = ("but" + i + "ton").hashCode();//generating a unique but knowable id
							b.setId(bID);
							constraintLayout.addView(b);
							b.setLayoutParams(new ConstraintLayout.LayoutParams(16, 16));
							if (i == -1) {
								constraintSet.connect(bID, ConstraintSet.TOP, R.id.QuestionText, ConstraintSet.BOTTOM, 8);
							} else {
								constraintSet.connect(bID, ConstraintSet.TOP, ("Text" + (i - 1) + "View").hashCode(), ConstraintSet.BOTTOM, 8);
							}
							final int marginRight = screenWidth >> 1;
							constraintSet.connect(bID, ConstraintSet.RIGHT, R.id.QuestionDisplayLayout, ConstraintSet.RIGHT, marginRight);
							final int marginBot = ((amountOptions - i) * (3 * screenHeight / 4)) / (amountOptions);
							constraintSet.connect(bID, ConstraintSet.BOTTOM, R.id.QuestionDisplayLayout, ConstraintSet.BOTTOM, marginBot);
							constraintSet.connect(bID, ConstraintSet.LEFT, R.id.QuestionDisplayLayout, ConstraintSet.LEFT, 8);
							b.requestLayout();
							
							tv.setText(o.getAnswerText());
							int tvID = (i == (amountOptions - 1)) ? "last".hashCode() : ("Text" + i + "View").hashCode();//generating a unique but knowable id
							sv.setId(tvID);
							constraintLayout.addView(sv);
							sv.setLayoutParams(new ConstraintLayout.LayoutParams(16, 16));
							constraintSet.connect(tvID, ConstraintSet.TOP, bID, ConstraintSet.TOP, 0);
							constraintSet.connect(tvID, ConstraintSet.RIGHT, R.id.QuestionDisplayLayout, ConstraintSet.RIGHT, 8);
							constraintSet.connect(tvID, ConstraintSet.BOTTOM, R.id.QuestionDisplayLayout, ConstraintSet.BOTTOM, marginBot);
							constraintSet.connect(tvID, ConstraintSet.LEFT, bID, ConstraintSet.RIGHT, marginRight / 16);
							sv.requestLayout();
							break;
						case EnterText:
							b = new Button(this);
							EditText et = new EditText(this);
							
							final int etindex = i;
							b.setOnClickListener(new View.OnClickListener() {
								final int buttonInd = etindex;
								
								@Override
								public void onClick(final View v) {
									optionClickHandlerMultiple(buttonInd);
								}
							});
							
							b.setText(String.format(Locale.GERMAN, "%d." + o.getAnswerText(), i));
							int etbID = ("but" + i + "ton").hashCode();//generating a unique but knowable id
							b.setId(etbID);
							constraintLayout.addView(b);
							b.setLayoutParams(new ConstraintLayout.LayoutParams(16, 16));
							if (i == -1) {
								constraintSet.connect(etbID, ConstraintSet.TOP, R.id.QuestionText, ConstraintSet.BOTTOM, 8);
							} else {
								constraintSet.connect(etbID, ConstraintSet.TOP, ("Text" + (i - 1) + "View").hashCode(), ConstraintSet.BOTTOM, 8);
							}
							final int etmarginRight = screenWidth >> 1;
							constraintSet.connect(etbID, ConstraintSet.RIGHT, R.id.QuestionDisplayLayout, ConstraintSet.RIGHT, etmarginRight);
							final int etmarginBot = ((amountOptions - i) * (3 * screenHeight / 4)) / (amountOptions);
							constraintSet.connect(etbID, ConstraintSet.BOTTOM, R.id.QuestionDisplayLayout, ConstraintSet.BOTTOM, etmarginBot);
							constraintSet.connect(etbID, ConstraintSet.LEFT, R.id.QuestionDisplayLayout, ConstraintSet.LEFT, 8);
							b.requestLayout();
							
							// EditText - setHint and no setText
							et.setHint("Hier eingeben");
							
							int ettvID = (i == (amountOptions - 1)) ? "last".hashCode() : ("Text" + i + "View").hashCode();//generating a unique but knowable id
							et.setId(ettvID);
							constraintLayout.addView(et);
							et.setLayoutParams(new ConstraintLayout.LayoutParams(32, 16));
							constraintSet.connect(ettvID, ConstraintSet.TOP, etbID, ConstraintSet.TOP, 0);
							constraintSet.connect(ettvID, ConstraintSet.RIGHT, R.id.QuestionDisplayLayout, ConstraintSet.RIGHT, 8);
							constraintSet.connect(ettvID, ConstraintSet.BOTTOM, R.id.QuestionDisplayLayout, ConstraintSet.BOTTOM, etmarginBot);
							constraintSet.connect(ettvID, ConstraintSet.LEFT, etbID, ConstraintSet.RIGHT, etmarginRight / 16);
							et.requestLayout();
							break;
						case Slider:
							//TODO
							//slider up to customer at later point
							break;
					}
					optionButtons.add(b);
				}
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
		constraintSet.connect(nbID, ConstraintSet.RIGHT, R.id.QuestionDisplayLayout, ConstraintSet.RIGHT, 8);
		constraintSet.connect(nbID, ConstraintSet.BOTTOM, R.id.QuestionDisplayLayout, ConstraintSet.BOTTOM, 8);
		constraintSet.connect(nbID, ConstraintSet.LEFT, R.id.QuestionDisplayLayout, ConstraintSet.LEFT, screenWidth >> 1);
		constraintSet.constrainHeight(nbID, NEXT_BUTTON_PIXEL_SIZE);
		constraintSet.constrainWidth(nbID, NEXT_BUTTON_PIXEL_SIZE);
		
		constraintSet.applyTo(constraintLayout);
		//constraintLayout.setConstraintSet(constraintSet);
	}
	
	private ConstraintLayout getButtonTextBoundingLayout(final int buttonPixelSize, final int buttonID, final Option option, final QuestionType qType) {
		if (option == null || qType == null || optionButtons == null) {
			throw new NullPointerException("tried to create container for button/text(/slider), but some argument was null, or optionButtons was null");
		}
		
		final ConstraintLayout container = new ConstraintLayout(this);
		final int containerID = HASH_MULTIPLIER_CONSTANT * option.hashCode() + buttonID;
		container.setId(containerID);
		
		switch (qType) {
			case SingleChoice:
				switch (option.getType()) {
					case StaticText:
						final RadioButton button = new RadioButton(this);
						button.setChecked(false);
						final TextView text = new TextView(this);
						
						button.setOnClickListener(new View.OnClickListener() {
							final int buttonInd = buttonID;
							
							@Override
							public void onClick(final View v) {
								optionClickHandlerSingle(buttonInd);
							}
						});
						optionButtons.add(button);
						final int buttonViewID = ("But" + buttonID + "ton").hashCode();
						button.setId(buttonViewID);
						final int textID = ("Text" + buttonID + "View").hashCode();
						text.setId(textID);
						button.setText("");
						text.setText(option.getAnswerText());
						
						button.setLayoutParams(new ConstraintLayout.LayoutParams(buttonPixelSize, buttonPixelSize));
						button.setMaxHeight(buttonPixelSize);
						button.setMaxWidth(buttonPixelSize);
						button.setMinHeight(buttonPixelSize);
						button.setMinWidth(buttonPixelSize);
						text.setLayoutParams(new ConstraintLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT));
						
						//constraintLayout.addView(button);
						//constraintLayout.addView(text);
						container.addView(button);
						container.addView(text);
						
						constraintSet.connect(buttonViewID, ConstraintSet.LEFT, containerID, ConstraintSet.LEFT, BUTTON_LEFT_RIGHT_MARGIN);
						constraintSet.connect(buttonViewID, ConstraintSet.RIGHT, containerID, ConstraintSet.RIGHT, BUTTON_LEFT_RIGHT_MARGIN);
						constraintSet.connect(buttonViewID, ConstraintSet.TOP, textID, ConstraintSet.TOP, BUTTON_TOP_BOTTOM_MARGIN);
						constraintSet.connect(buttonViewID, ConstraintSet.BOTTOM, textID, ConstraintSet.BOTTOM, BUTTON_TOP_BOTTOM_MARGIN);
						constraintSet.setHorizontalBias(buttonViewID, BUTTON_HORIZONTAL_BIAS);
						constraintSet.constrainMinHeight(buttonViewID, buttonPixelSize);
						constraintSet.constrainHeight(buttonViewID, buttonPixelSize + 2 * BUTTON_TOP_BOTTOM_MARGIN);
						constraintSet.constrainMaxHeight(buttonViewID, buttonPixelSize + 2 * BUTTON_TOP_BOTTOM_MARGIN);
						constraintSet.constrainMinWidth(buttonViewID, buttonPixelSize);
						constraintSet.constrainWidth(buttonViewID, buttonPixelSize + 2 * BUTTON_LEFT_RIGHT_MARGIN);
						constraintSet.constrainMaxWidth(buttonViewID, buttonPixelSize + 2 * BUTTON_LEFT_RIGHT_MARGIN);
						constraintSet.setVisibility(buttonViewID, ConstraintSet.VISIBLE);
						
						constraintSet.connect(textID, ConstraintSet.LEFT, buttonViewID, ConstraintSet.RIGHT, TEXT_MARGINS);
						constraintSet.connect(textID, ConstraintSet.RIGHT, containerID, ConstraintSet.RIGHT, TEXT_MARGINS);
						constraintSet.connect(textID, ConstraintSet.TOP, containerID, ConstraintSet.TOP, TEXT_MARGINS);
						constraintSet.connect(textID, ConstraintSet.BOTTOM, containerID, ConstraintSet.BOTTOM, TEXT_MARGINS);
						constraintSet.constrainMinHeight(textID, buttonPixelSize);
						constraintSet.constrainHeight(textID, buttonPixelSize);
						constraintSet.constrainMaxHeight(textID, ConstraintSet.MATCH_CONSTRAINT_WRAP);
						constraintSet.constrainMinWidth(textID, buttonPixelSize);
						constraintSet.constrainWidth(textID, ConstraintSet.MATCH_CONSTRAINT);
						constraintSet.constrainMaxWidth(textID, ConstraintSet.MATCH_CONSTRAINT);
						constraintSet.setVisibility(textID, ConstraintSet.VISIBLE);
						
						button.requestLayout();
						text.requestLayout();
						break;
					case EnterText:
						//TODO: enter text
						throw new IllegalStateException("was enter text");
					case Slider:
						//TODO: slider
						throw new IllegalStateException("was slider");
				}
				break;
			case MultipleChoice:
				//TODO:
				throw new IllegalStateException("was multiple choice");
			case Slider:
				//TODO:
				throw new IllegalStateException("was slider");
		}
		
		constraintSet.applyTo(container);
		//container.setConstraintSet(cSet);
		container.setLayoutParams(new ConstraintLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT));
		container.setMaxHeight(screenHeight);
		constraintSet.constrainMinHeight(containerID, buttonPixelSize);
		constraintSet.constrainHeight(containerID, buttonPixelSize);
		constraintSet.constrainMaxHeight(containerID, ConstraintSet.MATCH_CONSTRAINT_WRAP);
		constraintSet.constrainMinWidth(containerID, ConstraintSet.MATCH_CONSTRAINT);
		constraintSet.constrainWidth(containerID, ConstraintSet.MATCH_CONSTRAINT);
		constraintSet.constrainMaxWidth(containerID, ConstraintSet.MATCH_CONSTRAINT);
		
		return container;
	}
	
	void optionClickHandlerSingle(int pressedButton) {
		for (int i = 0; i < amountOptions; i++) {
			if (i == pressedButton) {
				pressedButtons.set(i, true);
				RadioButton rButton = (RadioButton) optionButtons.get(i);
				rButton.setChecked(true);
			} else {
				pressedButtons.set(i, false);
				RadioButton rButton = (RadioButton) optionButtons.get(i);
				rButton.setChecked(false);
			}
		}
	}
	
	/* handle next click */
	public void nextClick() {
		if (noneClicked()) {
			return;
		}
		//TODO: move next question information stuff to utility class
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
	
	private boolean noneClicked() {
		for (int i = 0; i < amountOptions; ++i) {
			if (pressedButtons.get(i)) {
				return false;
			}
		}
		return true;
	}
	
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
	
	void optionClickHandlerMultiple(int pressedButton) {
		for (int i = 0; i < amountOptions; i++) {
			if (i == pressedButton) {
				pressedButtons.set(i, !pressedButtons.get(i));
			}
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
		Toast myToast = Toast.makeText(this, "Vergiss es!", Toast.LENGTH_SHORT);
		myToast.show();
	}
	
	public void debugButtonClick(View view) {
		int firstID = containerIDs.get(0);
		ConstraintLayout firstContainer = findViewById(firstID);
		final int firstTop = firstContainer.getTop();
		final int firstLeft = firstContainer.getLeft();
		final int firstWidth = firstContainer.getWidth();
		final int firstHeight = firstContainer.getMaxHeight();
		Button firstButton = optionButtons.get(0);
		final int fbTop = firstButton.getTop();
		final int fbLeft = firstButton.getLeft();
		final int fbHeight = firstButton.getHeight();
		final int fbWidth = firstButton.getWidth();
		Toast myToast = Toast.makeText(this, "first container: x=" + firstLeft + ", y=" + firstTop + ", dx=" + firstWidth + ", dy=" + firstHeight + "\n" + "first Button: x=" + fbLeft + ", y=" + fbTop + ", dx=" + fbWidth + ", dy=" + fbHeight, Toast.LENGTH_SHORT);
		myToast.show();
	}
}
