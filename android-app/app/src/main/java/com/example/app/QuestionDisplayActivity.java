package com.example.app;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.Toast;

import com.example.app.answer.Answer;
import com.example.app.answer.Condition;
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
		// init current question
		final Question currentQuestion = questionView.getQuestion();
		
		// check edit time
		if (currentQuestion.editTime != null) {
			// TODO: comment this completely
			// if the time for the question is up, return a dummy as answer
			if (System.currentTimeMillis() > state.getCurrentQuestionEndTime()) {
				List<Condition> dummyCondition = new ArrayList<>(1);
				List <Answer> dummyAnswer = new ArrayList<>(1);
				dummyCondition.add(new Condition(currentQuestion.questionID, -1));
				// TODO: complete the dummy answer
				dummyAnswer.add(new Answer());
				state.currentQuestionAnswered(dummyAnswer, dummyCondition);
			} else {
				List<Condition> conditions = questionView.getCurrentCondition();
				List<Answer> answers = questionView.getCurrentAnswer();
				state.currentQuestionAnswered(answers, conditions);
			}
		} else {
			List<Condition> conditions = questionView.getCurrentCondition();
			List<Answer> answers = questionView.getCurrentAnswer();
			state.currentQuestionAnswered(answers, conditions);
		}
		
		if (state.getEndTime() != null) {
			final Date currentDate = new Date();
			if (currentDate.after(state.getEndTime())) {
				Intent intent = new Intent(this, QuestionnaireFinishedActivity.class);
				intent.putExtra("EXTRA_ANSWERS", conditionListToString());
				startActivity(intent);
				finish();
				return;
			}
		}
		
		
		if (!state.isFinished()) {
			displayCurrentQuestion(state, this);
		} else {
			Intent intent = new Intent(this, QuestionnaireFinishedActivity.class);
			intent.putExtra("EXTRA_ANSWERS", conditionListToString());
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
	private String conditionListToString() {
		List<Condition> conditionList = state.getConditions();
		StringBuilder returnString = new StringBuilder();
		for (Condition condition : conditionList) {
			returnString.append(condition);
			returnString.append("\n");
		}
		return returnString.toString();
	}
	
	// set next button to enabled or disabled
	public void setNextButtonEnabled(boolean enabled) {
		nextButton.setEnabled(enabled);
	}
}
