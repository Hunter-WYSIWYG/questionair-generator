package com.example.app;

import android.content.Intent;
import android.graphics.Point;
import android.os.Bundle;
import android.support.constraint.ConstraintLayout;
import android.support.constraint.ConstraintSet;
import android.support.v7.app.AppCompatActivity;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;
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
		
		Point sSize = new Point();
		getWindowManager().getDefaultDisplay().getSize(sSize);
		final int screenWidth = sSize.x;
		final int screenHeight = sSize.y;
		
		constraintLayout = findViewById(R.id.QuestionDisplayLayout);
		constraintSet = new ConstraintSet();
		constraintSet.clone(constraintSet);
		
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
		
		Toast toast = Toast.makeText(this, "result: " + current + ", " + qList.size() + ", " + qList.get(current).getType(), Toast.LENGTH_LONG);
		toast.show();
		
		currentQ = qList.get(current);
		
		TextView qid = findViewById(R.id.QuestionID);
		qid.setText("Frage #" + currentQ.getId());
		
		TextView qt = findViewById(R.id.QuestionText);
		qt.setText(currentQ.getTitle());
		qt.requestLayout();//redraw with new text
		
		List<Option> options = currentQ.getOptionList();
		amountOptions = options.size();
		optionButtons = new ArrayList<>(amountOptions);
		pressedButtons = new ArrayList<>(amountOptions);
		for (int i = 0; i < amountOptions; i++) {
			pressedButtons.add(false);
		}
		
		switch (currentQ.getType()) {
			case SingleChoice:
				for (int i = 0; i < amountOptions; i++) {
					Option o = options.get(i);
					Button b = null;
					switch (o.getType()) {
						case StaticText:
							b = new Button(this);
							TextView tv = new TextView(this);
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
							if (i == 0) {
								constraintSet.connect(bID, ConstraintSet.TOP, R.id.QuestionText, ConstraintSet.BOTTOM, 8);
							} else {
								constraintSet.connect(bID, ConstraintSet.TOP, ("Text" + (i - 1) + "View").hashCode(), ConstraintSet.BOTTOM, 8);
							}
							final int marginRight = screenWidth >> 1;
							constraintSet.connect(bID, ConstraintSet.RIGHT, R.id.QuestionDisplayLayout, ConstraintSet.RIGHT, marginRight);
							final int marginBot = screenHeight / (i + 2);
							constraintSet.connect(bID, ConstraintSet.BOTTOM, R.id.QuestionDisplayLayout, ConstraintSet.BOTTOM, marginBot);
							constraintSet.connect(bID, ConstraintSet.LEFT, R.id.QuestionDisplayLayout, ConstraintSet.LEFT, 8);
							b.requestLayout();
							
							tv.setText(o.getAnswerText());
							int tvID = i == amountOptions - 1 ? "last".hashCode() : ("Text" + i + "View").hashCode();//generating a unique but knowable id
							tv.setId(tvID);
							constraintLayout.addView(tv);
							tv.setLayoutParams(new ConstraintLayout.LayoutParams(16, 16));
							constraintSet.connect(tvID, ConstraintSet.TOP, bID, ConstraintSet.TOP, 8);
							constraintSet.connect(tvID, ConstraintSet.RIGHT, R.id.QuestionDisplayLayout, ConstraintSet.RIGHT, 8);
							constraintSet.connect(tvID, ConstraintSet.BOTTOM, R.id.QuestionDisplayLayout, ConstraintSet.BOTTOM, marginBot);
							constraintSet.connect(tvID, ConstraintSet.LEFT, bID, ConstraintSet.RIGHT, marginRight >> 1);
							tv.requestLayout();
							//TODO
							//size?
							break;
						case EnterText:
							//TODO
							//enter text
							break;
						case Slider:
							//TODO
							//slider
							break;
					}
					optionButtons.add(b);
				}
				break;
			case MultipleChoice:
				for (int i = 0; i < amountOptions; i++) {
					Option o = options.get(i);
					Button b = null;
					switch (o.getType()) {
						case StaticText:
							b = new Button(this);
							TextView tv = new TextView(this);
							final int index = i;
							b.setOnClickListener(new View.OnClickListener() {
								final int buttonInd = index;
								
								@Override
								public void onClick(final View v) {
									optionClickHandlerMultiple(buttonInd);
								}
							});
							b.setText(String.format(Locale.GERMAN, "%d.", i));
							tv.setText(o.getAnswerText());
							//TODO
							//anchor correctly?
							//make them visible?
							break;
						case EnterText:
							//TODO
							//enter text
							break;
						case Slider:
							//TODO
							//slider
							break;
					}
					optionButtons.add(b);
				}
				break;
		}
		
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
	
	public void nextClick() {
		if (noneClicked()) {
			return;
		}
		if (current < size - 1) {
			Intent intent = new Intent(this, QuestionDisplayActivity.class);
			intent.putExtra("size", size);
			intent.putExtra("current", current + 1);
			for (int j = 0; j < size; j++) {
				intent.putExtra("q" + j, qList.get(j));
				intent.putExtra("a" + j, aList.get(j));
			}
			aList.set(current, calcAnswer());
			startActivity(intent);
		} else {
			// TODO
			Intent i = new Intent(this, SaveAnswersActivity.class);
			i.putExtra("size", size);
			for (int j = 0; j < size; j++) {
				i.putExtra("a" + j, aList.get(j));
				if (j == current) {
					i.putExtra("a" + j, calcAnswer());
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
		}
	}
	
	void optionClickHandlerMultiple(int pressedButton) {
		for (int i = 0; i < amountOptions; i++) {
			if (i == pressedButton) {
				pressedButtons.set(i, !pressedButtons.get(i));
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
						return new Answer(i);
					}
				}
				break;
			case MultipleChoice:
				break;
		}
		return new Answer();
	}
}
