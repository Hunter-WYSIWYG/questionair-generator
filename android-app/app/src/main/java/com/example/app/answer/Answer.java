package com.example.app.answer;

import com.example.app.question.QuestionType;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

public class Answer implements Serializable {
	// TODO : EVERYTHING
	
	private final QuestionType qType;
	private final int questionID;
	private final int optionID;
	private final List<Integer> chosenValues;
	
	private Answer() {
		qType = null;
		questionID = -1;
		optionID = -1;
		chosenValues = null;
	}
	
	public Answer(final int questionID, QuestionType questionType, int optionID) {
		this.questionID = questionID;
		this.optionID = optionID;
		if (questionType == QuestionType.SingleChoice) {
			qType = QuestionType.SingleChoice;
			chosenValues = new ArrayList<>(1);
			chosenValues.add(optionID);
		}
		else {
			qType = QuestionType.MultipleChoice;
			chosenValues = new ArrayList<>(1);
		}
	}
	
	public void AddAnswer(int chosenIndex) {
		if (qType != QuestionType.SingleChoice) {
			chosenValues.add(chosenIndex);
		}
	}
	
	public int getQuestionID() {
		return questionID;
	}
	
	public int getOptionID() {
		return optionID;
	}
	
	public QuestionType getQType() {
		return qType;
	}
	
	public List<Integer> getChosenValues() {
		return chosenValues;
	}
}
