package com.example.app.view;

import android.view.View;

import com.example.app.QuestionDisplayActivity;
import com.example.app.QuestionnaireState;
import com.example.app.answer.Answer;
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
	QuestionDisplayView(QuestionDisplayActivity activity) {
		this.activity = activity;
	}
	
	// create new view for the current question of the activity
	public static QuestionDisplayView create(QuestionDisplayActivity activity) {
		Question question = QuestionnaireState.getCurrentQuestion();
		
		if (question instanceof ChoiceQuestion)
			return new MultipleChoiceView(activity, (ChoiceQuestion) question);
		else if (question instanceof SliderQuestion)
			return new SliderView(activity, (SliderQuestion) question);
		else if (question instanceof PercentSliderQuestion)
			return new PercentSliderView(activity, (PercentSliderQuestion) question);
		else if (question instanceof Note)
			return new NoteView(activity, (Note) question);
		else if (question instanceof TableQuestion)
			return new TableView(activity, (TableQuestion) question);
		else if (question instanceof SliderButtonQuestion)
			return new SliderButtonView(activity, (SliderButtonQuestion) question);
		else
			throw new IllegalArgumentException();
		// TODO: implement other question views
	}
	
	// getter
	QuestionDisplayActivity getActivity() {
		return this.activity;
	}
	
	public abstract View getView();
	
	// get all answer
	@SuppressWarnings ("SameReturnValue")
	public abstract Answer getCurrentAnswer();
	
}
