package com.example.app.view;

import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
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
import com.example.app.answer.TableAnswer;
import com.example.app.question.TableQuestion;

import java.util.ArrayList;
import java.util.Collection;

public class TableView extends QuestionDisplayView {
	
	// the corresponding question
	private final TableQuestion question;
	// container of slider
	private ConstraintLayout container;
	// table
	private TableLayout table;
	// size of table
	private final double size;
	// list of all buttons
	private final Collection<Button> buttons = new ArrayList<>();
	// id of button
	private int buttonID;
	// current pressed button
	@Nullable
	private Button currentButton;
	
	// constructor
	TableView(QuestionDisplayActivity activity, TableQuestion question) {
		super(activity);
		this.question = question;
		size = this.question.size;
		currentButton = null;
		
		// start with button id = -1
		buttonID = -1;
		
		init();
	}
	
	private void init() {
		container = (ConstraintLayout) View.inflate(getActivity(), R.layout.table_view, null);
		
		// set questionTypeText
		TextView questionTypeTextView = container.findViewById(R.id.tableQuestionTypeText);
		questionTypeTextView.setText(question.type.name());
		
		// set questionText
		TextView questionTextView = container.findViewById(R.id.tableQuestionText);
		questionTextView.setText(question.questionText);
		
		// find dividingLine
		View dividingLine = container.findViewById(R.id.tableDividingLine);
		
		// set leftName
		VerticalTextView leftName = container.findViewById(R.id.leftName);
		leftName.setText(question.leftName);
		
		// set rightName
		VerticalTextView rightName = container.findViewById(R.id.rightName);
		rightName.setText(question.rightName);
		
		// set topName
		TextView topName = container.findViewById(R.id.topName);
		topName.setText(question.topName);
		
		// set bottomName
		TextView bottomName = container.findViewById(R.id.bottomName);
		bottomName.setText(question.bottomName);
		
		// create table
		createTable();
	}
	
	
	// create table
	private void createTable() {
		table = container.findViewById(R.id.tableView);
		table.setMinimumHeight(table.getWidth());
		for (int i = 0; i < size; i++) {
			TableRow tableRow = new TableRow(getActivity());
			
			// row set in the middle
			tableRow.setGravity(Gravity.CENTER);
			// add table row to table
			table.addView(tableRow);
			
			for (int j = 0; j < size; j++) {
				Button button = new Button(getActivity());
				// set color
				button.setBackgroundResource(R.drawable.table_button_default);
				// set id of button
				button.setId(idGenerator());
				// add button to button list
				buttons.add(button);
				// set a colour button if clicked
				button.setOnClickListener(v -> buttonClicked(button));
				// add button to table row
				tableRow.addView(button);
			}
		}
	}
	
	// enable or disable 'next' button depending on whether any button is checked
	// also disable other radio buttons if this is that kind of question
	private void buttonClicked(@NonNull Button button) {
		currentButton = button;
		button.setBackgroundResource(R.drawable.table_button_pressed);
		for (Button b : buttons) {
			if (b.getId() != button.getId()) {
				b.setBackgroundResource(R.drawable.table_button_default);
			}
			
		}
		updateNextButtonEnabled();
	}
	
	// enable or disable 'next' button depending on whether any button is checked
	private void updateNextButtonEnabled () {
		getActivity().setNextButtonEnabled(currentButton != null);
	}
	
	// return button id
	private int idGenerator() {
		buttonID++;
		return buttonID;
	}
	
	@Override
	public View getView() {
		return container;
	}

	@Nullable
	@Override
	public Answer getCurrentAnswer() {
		//these buttons are 0-indexed it seems. good job!
		assert currentButton != null;
		return new TableAnswer(question, currentButton.getId());
	}
}
