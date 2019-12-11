package com.example.app.answer;

import java.io.Serializable;

public class Condition implements Serializable {
	private final int questionID;
	private final int chosenValue;

	public Condition() {
		// qType = null;
		// chosenValues = null;
		questionID = -1;
		chosenValue = -1;
	}

	public Condition(int questionID, int chosenValue) {
		
		this.questionID = questionID;
		this.chosenValue = chosenValue;
		
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

	@Override
	public boolean equals(Object o) {
		if (this == o) return true;
		if (o == null || getClass() != o.getClass()) return false;
		Condition condition = (Condition) o;
		return questionID == condition.questionID &&
				chosenValue == condition.chosenValue;
	}


	public int getQId () {
		return questionID;
	}

	public int getChosenValue () {
		return chosenValue;
	}
	
	@Override
	public String toString () {
		return "{" + " questionID = " + questionID + ", chosenValue = " + chosenValue + '}';
	}
}
