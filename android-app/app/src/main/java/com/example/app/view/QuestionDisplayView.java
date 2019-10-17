package com.example.app.view;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.util.AttributeSet;
import android.view.View;
import android.widget.FrameLayout;
import com.example.app.QuestionDisplayActivity;
import com.example.app.QuestionnaireState;
import com.example.app.answer.Answer;
import com.example.app.question.ChoiceQuestion;
import com.example.app.question.Question;

public abstract class QuestionDisplayView extends FrameLayout {
	
	// the corresponding activity
	private final QuestionDisplayActivity activity;
	
	// constructor
	protected QuestionDisplayView(QuestionDisplayActivity activity) {
		super(activity);
		this.activity = activity;
	}
	
	// getter
	protected QuestionDisplayActivity getActivity() {
		return this.activity;
	}

	
	// create new view for the current question of the activity
	public static MultipleChoiceView create (QuestionDisplayActivity activity) {
		Question question = activity.getState().getCurrentQuestion();
		
		if (question instanceof ChoiceQuestion) {
			return new MultipleChoiceView(activity, (ChoiceQuestion) question);
		}
		return null;
		// TODO: implement other question views
	}
	
	// get all answer (for on click next button)
	public abstract Answer getCurrentAnswer ();
}
