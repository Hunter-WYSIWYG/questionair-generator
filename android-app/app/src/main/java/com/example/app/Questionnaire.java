package com.example.app;

import com.google.gson.annotations.SerializedName;

import java.io.Serializable;
import java.util.List;

public class Questionnaire implements Serializable {
	/**
	 * name
	 */
	@SerializedName("questionnaireName")
	private final String name;
	
	/**
	 * list of all questions
	 */
	@SerializedName("questions")
	private final List<Question> questionList;
	
	/**
	 * default, error constructor
	 */
	Questionnaire() {
		name = null;
		questionList = null;
	}
	
	public String getName() {
		return name;
	}
	
	public List<Question> getQuestionList() {
		return questionList;
	}
}
