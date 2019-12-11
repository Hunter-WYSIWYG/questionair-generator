package com.example.app.answer;

import java.io.Serializable;

public class Answer implements Serializable {
	// class completely defining answers for questions
	// TODO: complete this class using the scheme!!!
	
	// ID of the question this answer depends on
	private final int questionID;
	// ID of the specific answer chosen
	private final int answerID;
	// verbal text of the chosen answer
	private final String answerText;
	// TODO: add more data from the scheme
	
	public Answer() {
		
		// constructing an empty answer
		this.questionID = -1;
		this.answerID = -1;
		this.answerText = "dummy";
	}
	
	public Answer(int questionID, int answerID, String answerText) {
		
		// constructing the answer object with input
		this.questionID = questionID;
		this.answerID = answerID;
		this.answerText = answerText;
		
	}
	
	public int getQuestionID() {
		return questionID;
	}
	
	public int getAnswerID() {
		return answerID;
	}
	
	public String getAnswerText() {
		return answerText;
	}
	
	@Override
	public String toString() {
		// TODO: maybe ignore, maybe add more info once its gathered
		return "{ questionID = " + questionID + ", answerID = " + answerID + ", answerText = " + answerText + " }";
	}
	
}
