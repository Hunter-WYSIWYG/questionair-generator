package com.example.app;

import android.content.Intent;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.widget.Button;
import android.widget.LinearLayout;

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
		this.setContentView(R.layout.activity_question_display);
		
		this.nextButton = this.findViewById(R.id.QuestionDisplayNextButton);
		this.contentContainer = this.findViewById(R.id.QuestionDisplayContentContainer);
		
		this.questionView = QuestionDisplayView.create(this);
		
		// insert as the new first element, before the space filler and the next button
		this.contentContainer.addView(this.questionView.getView(), 0);
		
		this.nextButton.setOnClickListener(v -> this.nextButtonClicked());
	}
	
	// next button is clicked, update questionnaire state and go to next question
	private void nextButtonClicked() {
		QuestionnaireState.giveAnswer(questionView.getCurrentAnswer());
		if (QuestionnaireState.nextIsQuestion()) {
			Intent intent = new Intent(this, QuestionDisplayActivity.class);
			// starting our own activity (onCreate) with questionnaire state so we can save it
			startActivity(intent);
			// prevent the back button
			finish();
		}
		else {
			Intent intent = new Intent(this, QuestionnaireFinishedActivity.class);
			startActivity(intent);
			finish();
		}
	}
	
	// set next button to enabled or disabled
	public void setNextButtonEnabled(boolean enabled) {
		this.nextButton.setEnabled(enabled);
		
		// TODO: color 'next' button depending on enabled or not
	}
	
}
