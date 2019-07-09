package com.example.app;

import android.app.ActionBar;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.Point;
import android.os.Bundle;
import android.support.constraint.ConstraintLayout;
import android.support.constraint.ConstraintSet;
import android.support.v7.app.AppCompatActivity;
import android.view.Menu;
import android.view.View;
import android.widget.*;
import org.jetbrains.annotations.Contract;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

public class QuestionDisplayActivity extends AppCompatActivity {
	private int current;
	private int size;
	private List<Question> qList;
	private List<Answer> aList;
	private ConstraintLayout constraintLayout;
	private ConstraintSet constraintSet;
	
	private Question currentQ;
	private int amountOptions;
	private List<Button> optionButtons;
	private List<Boolean> pressedButtons;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_question_display);
		
		/* create Layout */
		
		Point sSize = new Point();
		getWindowManager().getDefaultDisplay().getSize(sSize);
		final int screenWidth = sSize.x;
		final int screenHeight = sSize.y;
		
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
		TextView questiontypeTV = (TextView)findViewById(R.id.qTypeText);
		switch (currentQ.getType()) {
			case SingleChoice:
				questiontypeTV.setText("Single-Choice-Frage");
				for (int i = -1; i < amountOptions; i++) {
					Option o;
					if(i>=0) {
						o = options.get(i);
					} else {
						o= new Option (-1,"Baseline Option",OptionType.StaticText);
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
								constraintSet.connect(bID, ConstraintSet.TOP,  ("Text" + (i - 1) + "View").hashCode(), ConstraintSet.BOTTOM, 8);
							}
							final int marginRight = screenWidth >> 1;
							constraintSet.connect(bID, ConstraintSet.RIGHT, R.id.QuestionDisplayLayout, ConstraintSet.RIGHT, marginRight);
							final int marginBot = ((amountOptions-i)*(3*screenHeight/4))/(amountOptions);
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
							constraintSet.connect(tvID, ConstraintSet.LEFT, bID, ConstraintSet.RIGHT, marginRight/16);
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
							
							b.setText(String.format(Locale.GERMAN, "%d."+o.getAnswerText(), i));
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
							final int etmarginBot = ((amountOptions-i)*(3*screenHeight/4))/(amountOptions);
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
							constraintSet.connect(ettvID, ConstraintSet.LEFT, etbID, ConstraintSet.RIGHT, etmarginRight/16);
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
			case MultipleChoice:
				questiontypeTV.setText("Multiple-Choice-Frage");
				for (int i = -1; i < amountOptions; i++) {
					Option o;
					if(i>=0) {
						o = options.get(i);
					} else {
						o= new Option (-1,"Baseline Option",OptionType.StaticText);
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
								constraintSet.connect(bID, ConstraintSet.TOP,  ("Text" + (i - 1) + "View").hashCode(), ConstraintSet.BOTTOM, 8);
							}
							final int marginRight = screenWidth >> 1;
							constraintSet.connect(bID, ConstraintSet.RIGHT, R.id.QuestionDisplayLayout, ConstraintSet.RIGHT, marginRight);
							final int marginBot = ((amountOptions-i)*(3*screenHeight/4))/(amountOptions);
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
							constraintSet.connect(tvID, ConstraintSet.LEFT, bID, ConstraintSet.RIGHT, marginRight/16);
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
							
							b.setText(String.format(Locale.GERMAN, "%d."+o.getAnswerText(), i));
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
							final int etmarginBot = ((amountOptions-i)*(3*screenHeight/4))/(amountOptions);
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
							constraintSet.connect(ettvID, ConstraintSet.LEFT, etbID, ConstraintSet.RIGHT, etmarginRight/16);
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
		nextButton.setText("next");
		int nbID = "nextButton".hashCode();
		nextButton.setId(nbID);
		nextButton.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(final View v) {
				nextClick();
			}
		});
		constraintLayout.addView(nextButton);
		constraintSet.connect(nbID, ConstraintSet.TOP, "last".hashCode(), ConstraintSet.BOTTOM, 8);
		constraintSet.connect(nbID, ConstraintSet.RIGHT, R.id.QuestionDisplayLayout, ConstraintSet.RIGHT, 8);
		constraintSet.connect(nbID, ConstraintSet.BOTTOM, R.id.QuestionDisplayLayout, ConstraintSet.BOTTOM, 8);
		constraintSet.connect(nbID, ConstraintSet.LEFT, R.id.QuestionDisplayLayout, ConstraintSet.LEFT, screenWidth >> 1);
		nextButton.setLayoutParams(new ConstraintLayout.LayoutParams(32, 32));
		nextButton.requestLayout();
		
		constraintLayout.setConstraintSet(constraintSet);
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
		Toast myToast = Toast.makeText(this, "Vergiss es!",
				Toast.LENGTH_SHORT);
		myToast.show();
	}
	/* handle next click */
	public void nextClick() {
		if (noneClicked()) {
			Toast nosel = Toast.makeText(this, "Bitte Eingabe tätigen!",
					Toast.LENGTH_SHORT);
			nosel.show();
			return;
		}
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
	
	@Contract(pure = true)
	private boolean noneClicked() {
		for (int i = 0; i < amountOptions; ++i) {
			if (pressedButtons.get(i)) {
				return false;
			}
		}
		return true;
	}
	
	void optionClickHandlerSingle(int pressedButton) {
		for (int i = 0; i < amountOptions; i++) {
			if (i == pressedButton) {
				pressedButtons.set(i, true);
				
			} else {
				pressedButtons.set(i, false);
			}
			Toast myToast = Toast.makeText(this, "Antwort gewählt: "+pressedButton,
					Toast.LENGTH_SHORT);
			myToast.show();
		}
	}
	
	void optionClickHandlerMultiple(int pressedButton) {
		for (int i = 0; i < amountOptions; i++) {
			if (i == pressedButton) {
				pressedButtons.set(i, !pressedButtons.get(i));
			}
			if(pressedButtons.get(pressedButton)==true) {
				Toast myToast = Toast.makeText(this, "Antwort gewählt: " + pressedButton, Toast.LENGTH_SHORT);
				myToast.show();
			} else {
				Toast myToast = Toast.makeText(this, "Antwort abgewählt: " + pressedButton, Toast.LENGTH_SHORT);
				myToast.show();
			}
		}
	}
	
	@org.jetbrains.annotations.NotNull
	@org.jetbrains.annotations.Contract(" -> new")
	private Answer calcAnswer() {
		switch (currentQ.getType()) {
			case SingleChoice:
				for (int i = 0; i < amountOptions; i++) {
					if (pressedButtons.get(i)) {
						return new Answer(QuestionType.SingleChoice,i);
					}
				}
				break;
			case MultipleChoice:
				Answer mult =new Answer(QuestionType.MultipleChoice,-1);
				for (int i = 0; i < amountOptions; i++) {
					if (pressedButtons.get(i)) {
						mult.AddAnswer(i);
					}
				}
				return mult;
		}
		return new Answer();
	}
}
