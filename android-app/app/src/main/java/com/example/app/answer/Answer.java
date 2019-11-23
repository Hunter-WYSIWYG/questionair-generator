package com.example.app.answer;

import com.example.app.question.QuestionType;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

public class Answer implements Serializable {
	private final int qId;
	private final int chosenValue;

	public Answer () {
		// qType = null;
		// chosenValues = null;
		qId = -1;
		chosenValue = -1;
	}

	public Answer (int qid, int chosenIndex) {
		
		qId = qid;
		chosenValue = chosenIndex;
		
	}

	/*
	public void AddAnswer (int chosenIndex) {
		if (qType == QuestionType.SingleChoice) {
			return;
		}
		else {
			chosenValues.add (chosenIndex);
			return;
		}

	}
	 */
	
	public boolean equals (Answer answer){
		if (answer.getChosenValue () == chosenValue && answer.getQId () == qId){
			return true;
		}
		
		return false;
	}

	public int getQId () {
		return qId;
	}

	public int getChosenValue () {
		return chosenValue;
	}
	
	@Override
	public String toString () {
		return "Answer {" + "Question-ID: " + qId + ", Answer-ID: " + chosenValue + '}';
	}
}
