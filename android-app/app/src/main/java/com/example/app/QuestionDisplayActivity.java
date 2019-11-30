package com.example.app;

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

	// is called when this activity is started
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_question_display);

		nextButton = findViewById(R.id.QuestionDisplayNextButton);
		contentContainer = findViewById(R.id.QuestionDisplayContentContainer);

		TimeTracker.setContext(this);
		questionView = QuestionDisplayView.create(this);

		// insert as the new first element, before the space filler and the next button
		contentContainer.addView(questionView.getView(), 0);

		nextButton.setOnClickListener(v -> nextButtonClicked());
	}

	// next button is clicked, update questionnaire state and go to next question
	private void nextButtonClicked() {
		if (TimeTracker.isTimeOver()) {
			startActivity(new Intent(this, QuestionnaireFinishedActivity.class));
			finish();
			return;
		}
		Answer answer = questionView.getCurrentAnswer();
		QuestionnaireState.giveAnswer(answer);
		if (QuestionnaireState.nextIsQuestion()) {
			startActivity(new Intent(this, QuestionDisplayActivity.class));
			finish();
		} else {
			startActivity(new Intent(this, QuestionnaireFinishedActivity.class));
			finish();
		}
	}

	// set next button to enabled or disabled
	public void setNextButtonEnabled(boolean enabled) {
		nextButton.setEnabled(enabled);

		// TODO: color 'next' button depending on enabled or not
	}
}
