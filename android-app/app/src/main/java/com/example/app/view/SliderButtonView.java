package com.example.app.view;

import android.support.constraint.ConstraintLayout;
import android.view.Gravity;
import android.view.View;
import android.widget.Button;
import android.widget.TableLayout;
import android.widget.TableRow;
import android.widget.TextView;

import com.example.app.QuestionDisplayActivity;
import com.example.app.R;
import com.example.app.answer.Answer;
import com.example.app.answer.Condition;
import com.example.app.question.Question;
import com.example.app.question.SliderButtonQuestion;

import java.util.ArrayList;
import java.util.List;

public class SliderButtonView extends QuestionDisplayView {
	
	// the corresponding question
	private final SliderButtonQuestion question;
	// container of slider
	private ConstraintLayout container;
	// table
	private TableLayout table;
	// size of table
	private final double size;
	// list of all buttons
	private final List<Button> buttons = new ArrayList<>();
	// id of button
	private int buttonID;
	// current pressed button
	private Button currentButton;
	
	
	// constructor
	public SliderButtonView (QuestionDisplayActivity activity, SliderButtonQuestion question) {
		super (activity);
		this.question = question;
		size = this.question.size;
		currentButton = null;
		
		
		// start with button id = -1
		buttonID = -1;
		
		init();
	}
	
	private void init () {
		container = (ConstraintLayout) View.inflate(getActivity(), R.layout.slider_button_view, null);
		
		// set questionTypeText
		TextView questionTypeTextView = container.findViewById(R.id.sliderButtonQuestionTypeText);
		questionTypeTextView.setText(question.type.name());
		
		// set question Number
		TextView questionNumber = container.findViewById(R.id.questionNumber);
		questionNumber.setText("Fragenummer: " + question.questionID);
		
		// set questionText
		TextView questionTextView = container.findViewById(R.id.sliderButtonQuestionText);
		questionTextView.setText(question.questionText);
		
		// set hint
		TextView hintTextView = this.container.findViewById(R.id.hint);
		hintTextView.setText(this.question.hint);
		
		// find dividingLine
		View dividingLine = container.findViewById(R.id.sliderButtonDividingLine);
		
		// set leftIndex
		TextView leftIndex = container.findViewById(R.id.leftIndex);
		leftIndex.setText(question.leftIndex);
		
		// set rightIndex
		TextView rightIndex = container.findViewById(R.id.rightIndex);
		rightIndex.setText(question.rightIndex);
		
		// create table
		createTable();
	}
	
	
	// create table
	private void createTable(){
		table = container.findViewById(R.id.sliderButtonView);
		table.setMinimumHeight(table.getWidth());
		TableRow tableRow = new TableRow(getActivity());
			
		// row set in the middle
		tableRow.setGravity (Gravity.CENTER);
		// add 1 table row to table
		table.addView(tableRow);
		
		for (int j = 0; j < size; j++) {
			Button button = new Button(getActivity());
			// set color and number
			button.setBackgroundResource (R.drawable.table_button_default);
			button.setText ((j+1) + "");
			// set id of button
			button.setId(idGenerator());
			// add button to button list
			buttons.add(button);
			// set a colour button if clicked
			button.setOnClickListener(v -> buttonClicked(button));
			// add button to table row
			tableRow.addView (button);
			}
	}
	// enable or disable 'next' button depending on whether any button is checked
	// also disable other radio buttons if this is that kind of question
	private void buttonClicked (Button button) {
		currentButton = button;
		button.setBackgroundResource (R.drawable.table_button_pressed);
		for (Button b : buttons) {
			if (b.getId () != button.getId ()) {
				b.setBackgroundResource (R.drawable.table_button_default);
			}
			
		}
		updateNextButtonEnabled();
	}
	// enable or disable 'next' button depending on whether any button is checked
	private void updateNextButtonEnabled () {
		boolean enabled = false;
		if (currentButton != null)
			enabled = true;
		getActivity().setNextButtonEnabled(enabled);
	}
	
	// return button id
	private int idGenerator () {
		buttonID++;
		return buttonID;
	}
	
	@Override
	public View getView () {
		return container;
	}
	
	@Override
	public List<Condition> getCurrentCondition() {
		List<Condition> returnList = new ArrayList<>();
		returnList.add(new Condition(question.questionID, Integer.parseInt(currentButton.getText().toString())));
		return returnList;
	}
	
	@Override
	public List<Answer> getCurrentAnswer() {
		return new ArrayList<>();
	}
	
	@Override
	public Question getQuestion() {
		return question;
	}
}
