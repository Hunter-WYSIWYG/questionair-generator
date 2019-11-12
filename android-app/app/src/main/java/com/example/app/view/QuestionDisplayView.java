package com.example.app.view;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.support.constraint.ConstraintLayout;
import android.util.AttributeSet;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;

import com.example.app.QuestionDisplayActivity;
import com.example.app.QuestionnaireState;
import com.example.app.answer.Answer;
import com.example.app.question.*;

public abstract class QuestionDisplayView {

	// the corresponding activity
	private final QuestionDisplayActivity activity;

	// constructor
	protected QuestionDisplayView (QuestionDisplayActivity activity) {
		this.activity = activity;
	}

	// getter
	protected QuestionDisplayActivity getActivity () {
		return this.activity;
	}


	// create new view for the current question of the activity
	public static QuestionDisplayView create (QuestionDisplayActivity activity) {
		Question question = activity.getState ().getCurrentQuestion ();

		if (question instanceof ChoiceQuestion)
			return new MultipleChoiceView (activity, (ChoiceQuestion) question);
		else if (question instanceof SliderQuestion)
			return new SliderView (activity, (SliderQuestion) question);
		else if (question instanceof Note)
			return new NoteView (activity, (Note) question);
		else if (question instanceof TableQuestion)
			return new TableView (activity, (TableQuestion) question);
		else if(question instanceof SliderButtonQuestion)
			return new SliderButtonView (activity, (SliderButtonQuestion) question);
		else
			throw new IllegalArgumentException ();
		// TODO: implement other question views
	}

	public abstract View getView ();
	// get all answer
	public abstract Answer getCurrentAnswer ();

}
