package com.example.app.view;

import android.support.constraint.ConstraintLayout;
import android.view.View;
import android.widget.TextView;

import com.example.app.QuestionDisplayActivity;
import com.example.app.R;
import com.example.app.answer.Answer;
import com.example.app.question.Note;

public class NoteView extends QuestionDisplayView {
	
	// the corresponding question
	private final Note question;
	// container of slider
	private ConstraintLayout container;
	// actual note
	
	
	// constructor
	public NoteView (QuestionDisplayActivity activity, Note question) {
		super (activity);
		this.question = question;
		
		init();
	}
	
	private void init () {
		container = (ConstraintLayout) View.inflate(getActivity(), R.layout.note_view, null);
		
		// set questionTypeText
		TextView questionTypeTextView = container.findViewById(R.id.NoteTypeText);
		questionTypeTextView.setText ("Notiz");
		
		// set questionText
		TextView questionTextView = container.findViewById(R.id.NoteViewText);
		questionTextView.setText(question.questionText);
		
		// next button always enabled
		getActivity().setNextButtonEnabled(true);
	}
	
	
	
	@Override
	public View getView () {
		return container;
	}
	
	@Override
	public Answer getCurrentAnswer () {
		return null;
	}
}
