package com.example.app;

import android.widget.Toast;

import com.example.app.answer.Answer;
import com.example.app.question.Question;
import com.example.app.question.Questionnaire;
import com.google.gson.annotations.SerializedName;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

// current state of questionnaire with answers
public class QuestionnaireState implements Serializable {
	@SerializedName ("questionnaire")
	private final Questionnaire questionnaire;
	@SerializedName ("currentIndex")
	private int currentIndex;
	@SerializedName ("answers") private final List<Answer> answers = new ArrayList<>();

	// constructor, creates a new QuestionnaireState that starts at the first question
	public QuestionnaireState (Questionnaire questionnaire) {
		this.questionnaire = questionnaire;
		currentIndex = 0;
		
		goToNextPossibleQuestion();
	}

	// goes to next question, skip zero or more questions if necessary (conditions)
	private void goToNextPossibleQuestion () {
		if (!this.isFinished () && !this.isCurrentQuestionPossible () ) {
			this.currentIndex++;
			this.goToNextPossibleQuestion ();
		}
	}

	// next button clicked -> current question answered and go to next question
	public void currentQuestionAnswered (List<Answer> answer) {
		this.answers.addAll (answer);
		this.currentIndex++;
		this.goToNextPossibleQuestion ();
	}

	// return true if there is no question left
	public boolean isFinished () {
		return currentIndex >= questionnaire.getQuestionList().size();
	}

	// test conditions and see if you can display this question
	private boolean isCurrentQuestionPossible () {

		return this.answers.containsAll(this.questionnaire.getQuestionList().get(currentIndex).conditions);

		// TODO: test conditions
		// TODO: what to do if you are after the last question
	}

	// getter
	public int getCurrentIndex () {
		return currentIndex;
	}

	public Questionnaire getQuestionnaire () {
		return questionnaire;
	}

	public Question getCurrentQuestion () {
		return questionnaire.getQuestionList().get(currentIndex);
	}
	
	public List<Answer> getAnswers () {
		return this.answers;
	}


	// TODO: method saveCurrentState
}
