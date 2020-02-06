package com.example.app.view;

import android.content.SharedPreferences;
import android.support.constraint.ConstraintLayout;
import android.view.View;
import android.widget.TextView;

import com.example.app.QuestionDisplayActivity;
import com.example.app.QuestionnaireState;
import com.example.app.R;
import com.example.app.answer.Answer;
import com.example.app.answer.AnswerCollection;
import com.example.app.question.Note;
import com.example.app.question.QuestionType;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;

import static com.example.app.MainActivity.username;

public class NoteView extends QuestionDisplayView {
	
	// the corresponding question
	private final Note question;
	// container of slider
	private ConstraintLayout container;
	// current state
	private QuestionnaireState questionnaireState;
	
	// constructor
	public NoteView (QuestionDisplayActivity activity, Note question, QuestionnaireState state) {
		super (activity);
		this.question = question;
		this.questionnaireState = state;
		this.init ();
	}
	
	private void init () {
		this.container = (ConstraintLayout) View.inflate (this.getActivity (), R.layout.note_view, null);
		
		
		// set questionText
		TextView questionTextView = this.container.findViewById (R.id.NoteViewText);
		questionTextView.setText (this.question.questionText);
		
		// next button always enabled
		this.getActivity ().setNextButtonEnabled (true);
	}
	
	// getter
	@Override
	public View getView () {
		return this.container;
	}
	
	@Override
	public AnswerCollection getCurrentAnswer () {
		Calendar calendar = Calendar.getInstance (); // gets current instance of the calendar
		Answer answer = new Answer (QuestionType.Note.toString (), -1 , "");
		List<Answer> answerList = new ArrayList<Answer> ();
		answerList.add (answer);
		AnswerCollection answerCollection = new AnswerCollection (this.questionnaireState.getQuestionnaire ().getName (), getPreferenceValue (), calendar.getTime (), (int) (this.questionnaireState.getQuestionnaire ().getID ()), this.question.type, this.question.id, this.question.questionText, answerList);
		return answerCollection;
	}

	// get shared preference username
	public String getPreferenceValue ()	{
		SharedPreferences sp = this.getActivity ().getSharedPreferences (username, 0);
		String str = sp.getString ("key","");
		return str;
	}
}