package com.example.app;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.widget.*;

import com.example.app.answer.Answer;
import com.example.app.question.ChoiceQuestion;
import com.example.app.question.QuestionType;
import com.example.app.view.QuestionDisplayView;

import java.util.List;

public class QuestionDisplayActivity extends AppCompatActivity {
	
	// xml is divided into the questionViewContainer, the questionView inside the container and the "next" button
	private LinearLayout contentContainer;
	private QuestionDisplayView questionView;
	private Button nextButton;
	
	private QuestionnaireState state;
	
	// getter
	public QuestionnaireState getState () {
		return this.state;
	}
	
	// displays the current question of the questionnaire state
	public static void displayCurrentQuestion (QuestionnaireState questionnaireState, Activity activity) {
		Intent intent = new Intent (activity, QuestionDisplayActivity.class);
		intent.putExtra ("state", questionnaireState);
		activity.startActivity (intent); // starting our own activity (onCreate) with questionnaire state so we can save it
		activity.finish (); // prevent the back button
		// TODO: if back button pressed -> popup with "sind sie sicher dass sie den fragebogen abbrechen wollen?"
	}
	
	// is called when this activity is started
	@Override
	protected void onCreate (Bundle savedInstanceState) {
		super.onCreate (savedInstanceState);
		this.setContentView (R.layout.activity_question_display);
		
		this.state = (QuestionnaireState) this.getIntent ().getSerializableExtra ("state");
		this.nextButton = this.findViewById (R.id.QuestionDisplayNextButton);
		this.contentContainer = this.findViewById (R.id.QuestionDisplayContentContainer);
		
		this.questionView = QuestionDisplayView.create (this);
		
		// insert as the new first element, before the space filler and the next button
		this.contentContainer.addView (this.questionView.getView (), 0);
		
		this.nextButton.setOnClickListener (v -> this.nextButtonClicked ());
	}
	
	
	// set next button to enabled or disabled
	public void setNextButtonEnabled (boolean enabled) {
		this.nextButton.setEnabled (enabled);
	}
	
	// next button is clicked, update questionnaire state and go to next question
	private void nextButtonClicked () {
		List<Answer> answer = this.questionView.getCurrentAnswer ();
		this.state.currentQuestionAnswered (answer);
		
		if (!this.state.isFinished ()) {
			displayCurrentQuestion (this.state, this);
		}
		else {
			Intent intent = new Intent (this, QuestionnaireFinishedActivity.class);
			this.startActivity (intent);
			this.finish ();
		}
	}
	
}
