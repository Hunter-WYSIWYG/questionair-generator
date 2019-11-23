package com.example.app.view;

import android.support.constraint.ConstraintLayout;
import android.view.Gravity;
import android.view.View;
import android.widget.*;

import com.example.app.QuestionDisplayActivity;
import com.example.app.R;
import com.example.app.answer.Answer;
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
	private double size;
	// list of all buttons
	private List<Button> buttons = new ArrayList<> ();
	// id of button
	private int buttonID;
	// current pressed button
	private Button currentButton;
	
	
	// constructor
	public SliderButtonView (QuestionDisplayActivity activity, SliderButtonQuestion question) {
		super (activity);
		this.question = question;
		this.size = this.question.size;
		this.currentButton = null;
		
		
		// start with button id = -1
		this.buttonID = -1;
		
		this.init ();
	}
	
	private void init () {
		this.container = (ConstraintLayout) View.inflate (this.getActivity (), R.layout.slider_button_view, null);
		
		// set questionTypeText
		TextView questionTypeTextView = this.container.findViewById (R.id.sliderButtonQuestionTypeText);
		questionTypeTextView.setText (this.question.type.name ());
		
		// set question Number
		TextView questionNumber = this.container.findViewById (R.id.questionNumber);
		questionNumber.setText("Fragenummer: " + question.questionID);
		
		// set questionText
		TextView questionTextView = this.container.findViewById (R.id.sliderButtonQuestionText);
		questionTextView.setText (this.question.questionText);
		
		// find dividingLine
		View dividingLine = this.container.findViewById (R.id.sliderButtonDividingLine);
		
		// set leftIndex
		TextView leftIndex = this.container.findViewById (R.id.leftIndex);
		leftIndex.setText (this.question.leftIndex);
		
		// set rightIndex
		TextView rightIndex = this.container.findViewById (R.id.rightIndex);
		rightIndex.setText (this.question.rightIndex);
		
		// create table
		this.createTable();
	}
	
	
	// create table
	private void createTable(){
		this.table = this.container.findViewById (R.id.sliderButtonView);
		this.table.setMinimumHeight (this.table.getWidth ());
		TableRow tableRow = new TableRow (this.getActivity ());
			
		// row set in the middle
		tableRow.setGravity (Gravity.CENTER);
		// add 1 table row to table
		this.table.addView (tableRow);
			
		for(int j = 0; j < this.size; j++) {
			Button button = new Button (this.getActivity ());
			// set color and number
			button.setBackgroundResource (R.drawable.table_button_default);
			button.setText ((j+1) + "");
			// set id of button
			button.setId (this.idGenerator ());
			// add button to button list
			this.buttons.add (button);
			// set a colour button if clicked
			button.setOnClickListener (v -> this.buttonClicked (button));
			// add button to table row
			tableRow.addView (button);
			}
	}
	// enable or disable 'next' button depending on whether any button is checked
	// also disable other radio buttons if this is that kind of question
	private void buttonClicked (Button button) {
		this.currentButton = button;
		button.setBackgroundResource (R.drawable.table_button_pressed);
		for (Button b : buttons) {
			if (b.getId () != button.getId ()) {
				b.setBackgroundResource (R.drawable.table_button_default);
			}
			
		}
		this.updateNextButtonEnabled ();
	}
	// enable or disable 'next' button depending on whether any button is checked
	private void updateNextButtonEnabled () {
		boolean enabled = false;
		if (this.currentButton != null)
			enabled = true;
		this.getActivity ().setNextButtonEnabled (enabled);
	}
	
	// return button id
	private int idGenerator () {
		this.buttonID++;
		return buttonID;
	}
	
	@Override
	public View getView () {
		return this.container;
	}
	
	@Override
	public List<Answer> getCurrentAnswer () {
		//TODO: get real value of button
		List<Answer> returnList = new ArrayList<>();
		returnList.add (new Answer (this.question.questionID, Integer.parseInt(this.currentButton.getText().toString())));
		return returnList;
	}
}
