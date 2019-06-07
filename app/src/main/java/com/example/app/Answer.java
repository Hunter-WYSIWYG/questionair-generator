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
	
	public Answer(int chosenIndex) {
		qType = QuestionType.SingleChoice;
		chosenValues = new ArrayList<>(1);
		chosenValues.add(chosenIndex);
	}
	
	public QuestionType getqType() {
		return qType;
	}
	
	public List<Integer> getChosenValues() {
		return chosenValues;
	}
}
