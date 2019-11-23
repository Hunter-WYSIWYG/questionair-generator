package com.example.app.view;

import android.support.constraint.ConstraintLayout;
import android.view.Gravity;
import android.view.View;
import android.widget.*;

import com.example.app.QuestionDisplayActivity;
import com.example.app.R;
import com.example.app.answer.Answer;
import com.example.app.question.TableQuestion;

import java.util.ArrayList;
import java.util.List;

public class TableView extends QuestionDisplayView {
	
	// the corresponding question
	private final TableQuestion question;
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
	public TableView (QuestionDisplayActivity activity, TableQuestion question) {
		super (activity);
		this.question = question;
		this.size = this.question.size;
		this.currentButton = null;
		
		
		// start with button id = -1
		this.buttonID = -1;
		
		this.init ();
	}
	
	private void init () {
		this.container = (ConstraintLayout) View.inflate (this.getActivity (), R.layout.table_view, null);
		
		// set questionTypeText
		TextView questionTypeTextView = this.container.findViewById (R.id.tableQuestionTypeText);
		questionTypeTextView.setText (this.question.type.name ());
		
		// set question Number
		TextView questionNumber = this.container.findViewById (R.id.questionNumber);
		questionNumber.setText("Fragenummer: " + question.questionID);
		
		// set questionText
		TextView questionTextView = this.container.findViewById (R.id.tableQuestionText);
		questionTextView.setText (this.question.questionText);
		
		// find dividingLine
		View dividingLine = this.container.findViewById (R.id.tableDividingLine);
		
		// set leftName
		VerticalTextView leftName = this.container.findViewById (R.id.leftName);
		leftName.setText (this.question.leftName);
		
		// set rightName
		VerticalTextView rightName = this.container.findViewById (R.id.rightName);
		rightName.setText (this.question.rightName);
		
		// set topName
		TextView topName = this.container.findViewById (R.id.topName);
		topName.setText (this.question.topName);
		
		// set bottomName
		TextView bottomName = this.container.findViewById (R.id.bottomName);
		bottomName.setText (this.question.bottomName);
		
		// create table
		this.createTable();
	}
	
	
	// create table
	private void createTable(){
		this.table = this.container.findViewById (R.id.tableView);
		this.table.setMinimumHeight (this.table.getWidth ());
		for (int i = 0; i < this.size; i++) {
			TableRow tableRow = new TableRow (this.getActivity ());
			
			// row set in the middle
			tableRow.setGravity (Gravity.CENTER);
			// add table row to table
			this.table.addView (tableRow);
			
			for(int j = 0; j < this.size; j++) {
				Button button = new Button (this.getActivity ());
				// set color
				button.setBackgroundResource (R.drawable.table_button_default);
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
		//TODO: get the real value of the answer!
		List<Answer> returnList = new ArrayList<>();
		returnList.add (new Answer (this.question.questionID, -1));
		return returnList;
	}
}
