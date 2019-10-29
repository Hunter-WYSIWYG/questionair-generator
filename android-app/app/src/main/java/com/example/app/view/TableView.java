package com.example.app.view;

import android.support.constraint.ConstraintLayout;
import android.view.View;
import android.widget.TableLayout;
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
	
	private TableLayout table;
	
	// constructor
	public TableView (QuestionDisplayActivity activity, TableQuestion question) {
		super (activity);
		this.question = question;
		
		this.init ();
	}
	
	private void init () {
		this.container = (ConstraintLayout) View.inflate (this.getActivity (), R.layout.table_view, null);
		
		// Tabelle erstellen
		
		this.createTable();
		
		// set questionTypeText
		TextView questionTypeTextView = this.container.findViewById (R.id.TableTypeText);
		questionTypeTextView.setText ("Table View");
		
		// next button always enabled
		this.getActivity ().setNextButtonEnabled (true);
	}
	
	private void createTable(){
		this.table = this.container.findViewById (R.id.tableView);
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
