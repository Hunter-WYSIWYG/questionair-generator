package com.example.app.view;

import android.view.View;

import com.example.app.QuestionDisplayActivity;
import com.example.app.QuestionnaireState;
import com.example.app.answer.Answers;
import com.example.app.question.ChoiceQuestion;
import com.example.app.question.Note;
import com.example.app.question.PercentSliderQuestion;
import com.example.app.question.Question;
import com.example.app.question.SliderButtonQuestion;
import com.example.app.question.SliderQuestion;
import com.example.app.question.TableQuestion;

public abstract class QuestionDisplayView {

	// the corresponding activity
	private final QuestionDisplayActivity activity;

	// constructor
	protected QuestionDisplayView (QuestionDisplayActivity activity) {
		this.activity = activity;
	}

	// getter
	protected QuestionDisplayActivity getActivity () {
		return activity;
	}


	// create new view for the current question of the activity
	public static QuestionDisplayView create (QuestionDisplayActivity activity) {
		Question question = activity.getState ().getCurrentQuestion ();

		if (question instanceof ChoiceQuestion)
			return new MultipleChoiceView (activity, (ChoiceQuestion) question ,activity.getState());
		else if (question instanceof SliderQuestion)
			return new SliderView (activity, (SliderQuestion) question,activity.getState());
		else if (question instanceof PercentSliderQuestion)
			return new PercentSliderView (activity, (PercentSliderQuestion) question, activity.getState());
		else if (question instanceof Note)
			return new NoteView (activity, (Note) question, activity.getState());
		else if (question instanceof TableQuestion)
			return new TableView (activity, (TableQuestion) question, activity.getState());
		else if(question instanceof SliderButtonQuestion)
			return new SliderButtonView (activity, (SliderButtonQuestion) question, activity.getState());
		else
			throw new IllegalArgumentException ();
		// TODO: implement other question views
	}

	public abstract View getView ();
	// get all answer
	public abstract Answers getCurrentAnswer();

}
