package com.example.app;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.Toast;

import com.example.app.answer.Answer;
import com.example.app.question.Question;
import com.example.app.view.QuestionDisplayView;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class QuestionDisplayActivity extends AppCompatActivity {
	
	// xml is divided into the questionViewContainer, the questionView inside the container and the "next" button
	private LinearLayout contentContainer;
	private QuestionDisplayView questionView;
	private Button nextButton;
	
	private QuestionnaireState state;
	
	// getter
	public QuestionnaireState getState() {
		return state;
	}
	
	// is called when this activity is started
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_question_display);
		
		state = (QuestionnaireState) getIntent().getSerializableExtra("state");
		nextButton = findViewById(R.id.QuestionDisplayNextButton);
		contentContainer = findViewById(R.id.QuestionDisplayContentContainer);
		
		questionView = QuestionDisplayView.create(this);
		
		// insert as the new first element, before the space filler and the next button
		contentContainer.addView(questionView.getView(), 0);
		
		nextButton.setOnClickListener(v -> nextButtonClicked());
		
		Toast kek = Toast.makeText(this, state.getCurrentQuestion().conditions.toString(), Toast.LENGTH_LONG);
		kek.show();
	}
	
	// next button is clicked, update questionnaire state and go to next question
	private void nextButtonClicked() {
		final Question q = questionView.getQuestion();
		if (q.editTime != null) {
			if (System.currentTimeMillis() > state.getCurrentQuestionEndTime()) {
				List<Answer> dummy = new ArrayList<>(1);
				dummy.add(new Answer(q.questionID, -1));
				state.currentQuestionAnswered(dummy);
			} else {
				List<Answer> answer = questionView.getCurrentAnswer();
				state.currentQuestionAnswered(answer);
			}
		} else {
			List<Answer> answer = questionView.getCurrentAnswer();
			state.currentQuestionAnswered(answer);
		}
		
		if (state.getEndTime() != null) {
			final Date currentDate = new Date();
			if (currentDate.after(state.getEndTime())) {
				Intent intent = new Intent(this, QuestionnaireFinishedActivity.class);
				intent.putExtra("EXTRA_ANSWERS", answerListToString());
				startActivity(intent);
				finish();
				return;
			}
		}
		
		
		if (!state.isFinished()) {
			displayCurrentQuestion(state, this);
		} else {
			Intent intent = new Intent(this, QuestionnaireFinishedActivity.class);
			intent.putExtra("EXTRA_ANSWERS", answerListToString());
			startActivity(intent);
			finish();
		}
	}
	
	// displays the current question of the questionnaire state
	public static void displayCurrentQuestion(Serializable questionnaireState, Activity activity) {
		Intent intent = new Intent(activity, QuestionDisplayActivity.class);
		intent.putExtra("state", questionnaireState);
		activity.startActivity(intent); // starting our own activity (onCreate) with questionnaire state so we can save it
		activity.finish(); // prevent the back button
		// TODO: if back button pressed -> popup with "Sind Sie sicher, dass Sie den Fragebogen abbrechen wollen?"
	}
	
	//TODO: better solution for this
	private String answerListToString() {
		List<Answer> answerList = state.getAnswers();
		StringBuilder returnString = new StringBuilder();
		for (Answer answer : answerList) {
			returnString.append(answer);
			returnString.append("\n");
		}
		return returnString.toString();
	}
	
	// set next button to enabled or disabled
	public void setNextButtonEnabled(boolean enabled) {
		nextButton.setEnabled(enabled);
	}
}
