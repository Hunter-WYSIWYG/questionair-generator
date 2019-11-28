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
import com.example.app.answer.SliderButtonAnswer;
import com.example.app.question.SliderButtonQuestion;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Locale;

public class SliderButtonView extends QuestionDisplayView {

	// the corresponding question
	private final SliderButtonQuestion question;
	// size of table
	private final double size;
	// list of all buttons
	private final Collection<Button> buttons = new ArrayList<>();
	// container of slider
	private ConstraintLayout container;
	// table
	private TableLayout table;
	// id of button
	private int buttonID;
	// current pressed button
	@Nullable
	private Button currentButton;

	// constructor
	SliderButtonView(QuestionDisplayActivity activity, SliderButtonQuestion question) {
		super(activity);
		this.question = question;
		size = this.question.size;
		currentButton = null;

		// start with button id = -1
		buttonID = -1;

		init();
	}

	private void init() {
		container = (ConstraintLayout) View.inflate(getActivity(), R.layout.slider_button_view, null);

		// set questionTypeText
		TextView questionTypeTextView = container.findViewById(R.id.sliderButtonQuestionTypeText);
		questionTypeTextView.setText(question.type.name());

		// set questionText
		TextView questionTextView = container.findViewById(R.id.sliderButtonQuestionText);
		questionTextView.setText(question.questionText);

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
	private void createTable() {
		table = container.findViewById(R.id.sliderButtonView);
		table.setMinimumHeight(table.getWidth());
		TableRow tableRow = new TableRow(getActivity());

		// row set in the middle
		tableRow.setGravity(Gravity.CENTER);
		// add 1 table row to table
		table.addView(tableRow);

		for (int j = 0; j < size; j++) {
			Button button = new Button(getActivity());
			// set color and number
			button.setBackgroundResource(R.drawable.table_button_default);
			button.setText(String.format(Locale.GERMAN, "%d", j + 1));
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

	// return button id
	private int idGenerator() {
		buttonID++;
		return buttonID;
	}

	// enable or disable 'next' button depending on whether any button is checked
	private void updateNextButtonEnabled() {
		getActivity().setNextButtonEnabled(currentButton != null);
	}

	@Override
	public View getView() {
		return container;
	}

	@Nullable
	@Override
	public Answer getCurrentAnswer() {
		assert currentButton != null;
		return new SliderButtonAnswer(question, currentButton.getId());
	}
}
