package com.example.app;

import com.example.app.answer.Answer;
import com.example.app.answer.AnswerCollection;

import com.example.app.answer.Condition;
import com.example.app.question.Question;
import com.example.app.question.Questionnaire;
import com.google.gson.annotations.SerializedName;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

// current state of questionnaire with answerCollectionList
public class QuestionnaireState implements Serializable {
	@SerializedName ("questionnaire")
	private final Questionnaire questionnaire;
	@SerializedName ("currentIndex")
	private int currentIndex;
	@SerializedName ("answerCollectionList")
	private final List<AnswerCollection> answerCollectionList = new ArrayList<> ();
	
	// constructor, creates a new QuestionnaireState that starts at the first question
	public QuestionnaireState (Questionnaire questionnaire) {
		this.questionnaire = questionnaire;
		this.currentIndex = 0;
		this.goToNextPossibleQuestion ();
	}
	
	// goes to next question, skip zero or more questions if necessary (conditions)
	private void goToNextPossibleQuestion () {
		if (!this.isFinished () && !this.isCurrentQuestionPossible ()) {
			this.currentIndex++;
			this.goToNextPossibleQuestion ();
		}
	}
	
	// next button clicked -> current question answered and go to next question
	public void currentQuestionAnswered (AnswerCollection answerCollection) {
		this.answerCollectionList.add (answerCollection);
		this.currentIndex++;
		this.goToNextPossibleQuestion ();
	}
	
	// return true if there is no question left
	public boolean isFinished () {
		return this.currentIndex >= this.questionnaire.getQuestionList ().size ();
	}
	
	// test conditions and see if you can display this question
	private boolean isCurrentQuestionPossible () {
		for (Condition condition : this.questionnaire.getConditionList ()) {
			if (this.getCurrentQuestion ().id == condition.childId) {
				// test if condition is met
				boolean conditionMet = false;
				for (AnswerCollection answerCollection : this.answerCollectionList) {
					if(answerCollection.questionId == condition.parentId) {
						for (Answer answer : answerCollection.getAnswerList ()) {
							if (answer.id == condition.answerId)
								conditionMet = true;
						}
					}
				}
				if (!conditionMet)
					return false;
			}
		}
		return true;
	}
	
	// getter
	public int getCurrentIndex () {
		return currentIndex;
	}
	public Questionnaire getQuestionnaire () {
		return questionnaire;
	}
	public Question getCurrentQuestion () {
		return questionnaire.getQuestionList ().get (currentIndex);
	}
	public List<AnswerCollection> getAnswerCollectionList () {
		return answerCollectionList;
	}
}
