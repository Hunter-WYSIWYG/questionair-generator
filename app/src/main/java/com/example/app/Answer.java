package com.example.app;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

public class Answer implements Serializable {
	private final QuestionType qType;
	private final List<Integer> chosenValues;
	
	public Answer() {
		qType = null;
		chosenValues = null;
	}
	
	public Answer(QuestionType qtyp, int chosenIndex) {
		if (qtyp == QuestionType.SingleChoice) {
			qType = QuestionType.SingleChoice;
			chosenValues = new ArrayList<>(1);
			chosenValues.add(chosenIndex);
		} else {
			qType = QuestionType.MultipleChoice;
			chosenValues = new ArrayList<>(1);
		}
	}
	
	public void AddAnswer(int chosenIndex) {
		if (qType == QuestionType.SingleChoice) {
			return;
		} else {
			chosenValues.add(chosenIndex);
			return;
		}
		
	}
	
	public QuestionType getqType() {
		return qType;
	}
	
	public List<Integer> getChosenValues() {
		return chosenValues;
	}
}
