package com.example.app.view;

import android.support.constraint.ConstraintLayout;
import android.view.View;
import android.widget.TextView;

import com.example.app.QuestionDisplayActivity;
import com.example.app.R;
import com.example.app.answer.Answer;
import com.example.app.question.TableQuestion;

public class TableView extends QuestionDisplayView {
	
	// the corresponding question
	private final TableQuestion question;
	// container of slider
	private ConstraintLayout container;
	// actual note
	
	
	// constructor
	public TableView (QuestionDisplayActivity activity, TableQuestion question) {
		super (activity);
		this.question = question;
		
		this.init ();
	}
	
	private void init () {
		this.container = (ConstraintLayout) View.inflate (this.getActivity (), R.layout.table_view, null);
		
		// set questionTypeText
		TextView questionTypeTextView = this.container.findViewById (R.id.NoteTypeText);
		questionTypeTextView.setText ("Notiz");
		
		// set questionText
		TextView questionTextView = this.container.findViewById (R.id.NoteViewText);
		questionTextView.setText (this.question.questionText);
		
		// next button always enabled
		this.getActivity ().setNextButtonEnabled (true);
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
