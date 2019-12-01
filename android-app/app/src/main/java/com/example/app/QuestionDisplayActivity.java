package com.example.app;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.widget.Button;
import android.widget.LinearLayout;

import com.example.app.answer.Answer;
import com.example.app.view.QuestionDisplayView;

public class QuestionDisplayActivity extends AppCompatActivity {

	// xml is divided into the questionViewContainer, the questionView inside the container and the "next" button
	private LinearLayout contentContainer;
	private QuestionDisplayView questionView;
	private Button nextButton;

	private QuestionnaireState state;

	// getter
	public QuestionnaireState getState () {
		return state;
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
		setContentView(R.layout.activity_question_display);
		
		state = (QuestionnaireState) getIntent().getSerializableExtra("state");
		nextButton = findViewById(R.id.QuestionDisplayNextButton);
		contentContainer = findViewById(R.id.QuestionDisplayContentContainer);
		
		questionView = QuestionDisplayView.create(this);

		// insert as the new first element, before the space filler and the next button
		contentContainer.addView(questionView.getView(), 0);
		
		nextButton.setOnClickListener(v -> nextButtonClicked());
	}

	// next button is clicked, update questionnaire state and go to next question
	private void nextButtonClicked () {
		Answer answer = questionView.getCurrentAnswer();
		state.currentQuestionAnswered(answer);
		if (!state.isFinished()) {
			displayCurrentQuestion(state, this);
		}
		else {
			Intent intent = new Intent (this, QuestionnaireFinishedActivity.class);
			startActivity(intent);
			finish();
		}
	}
	
	// set next button to enabled or disabled
	public void setNextButtonEnabled(boolean enabled) {
		nextButton.setEnabled(enabled);
		
		// TODO: color 'next' button depending on enabled or not
	}

}
