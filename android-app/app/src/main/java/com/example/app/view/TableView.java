package com.example.app.view;

import android.support.constraint.ConstraintLayout;
import android.util.AttributeSet;
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
	
	
	// constructor
	public TableView (QuestionDisplayActivity activity, TableQuestion question) {
		super (activity);
		this.question = question;
		this.size = this.question.size;
		
		// start with button id = -1
		this.buttonID = -1;
		
		this.init ();
	}
	
	private void init () {
		this.container = (ConstraintLayout) View.inflate (this.getActivity (), R.layout.table_view, null);
		
		// set questionTypeText
		TextView questionTypeTextView = this.container.findViewById (R.id.TableQuestionTypeText);
		questionTypeTextView.setText (this.question.type.name ());
		
		// set questionText
		TextView questionTextView = this.container.findViewById (R.id.TableQuestionText);
		questionTextView.setText (this.question.questionText);
		
		// find dividingLine
		View dividingLine = this.container.findViewById (R.id.TableDividingLine);
		
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
		
		// TODO next button clicked method
		// next button always enabled (for now)
		this.getActivity ().setNextButtonEnabled (true);
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
				// set id of button
				button.setId (this.idGenerator ());
				// set layout of button
				//button.set
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
		button.setBackground (R.drawable.button_border);
		//this.updateNextButtonEnabled ();
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
	public Answer getCurrentAnswer () {
		return null;
	}
}
