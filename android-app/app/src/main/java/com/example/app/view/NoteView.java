package com.example.app.view;

import android.support.annotation.Nullable;
import android.support.constraint.ConstraintLayout;
import android.view.View;
import android.widget.TextView;

import com.example.app.QuestionDisplayActivity;
import com.example.app.QuestionnaireState;
import com.example.app.R;
import com.example.app.answer.Answer;
import com.example.app.answer.Answers;
import com.example.app.question.Note;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;

public class NoteView extends QuestionDisplayView {
	
	// the corresponding question
	private final Note question;
	// container of slider
	private ConstraintLayout container;
	// actual note
	//current State
	private QuestionnaireState qState;
	
	// constructor
	NoteView(QuestionDisplayActivity activity, Note question, QuestionnaireState state) {
		super(activity);
		this.question = question;
		qState=state;
		init();
	}
	
	private void init() {
		container = (ConstraintLayout) View.inflate(getActivity(), R.layout.note_view, null);
		
		// set questionTypeText
		TextView questionTypeTextView = container.findViewById(R.id.NoteTypeText);
		questionTypeTextView.setText(R.string.noteview_note);
		
		// set questionText
		TextView questionTextView = container.findViewById(R.id.NoteViewText);
		questionTextView.setText(question.questionText);
		
		// next button always enabled
		getActivity().setNextButtonEnabled(true);
	}
	
	
	@Override
	public View getView() {
		return container;
	}

	@Nullable
	@Override
	public Answers getCurrentAnswer() {
		Calendar calendar = Calendar.getInstance(); // gets current instance of the calendar
		Answer ans=new Answer(question.type.toString(),-1 , "");
		List<Answer> answerList=new ArrayList<Answer>();
		answerList.add(ans);
		Answers answers=new Answers(qState.getQuestionnaire().getName(),calendar.getTime(),(int) (qState.getQuestionnaire().getID()),question.type,question.id,question.questionText,answerList);
		return answers;
	}
}
