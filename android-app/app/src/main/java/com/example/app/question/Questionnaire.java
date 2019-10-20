package com.example.app.question;

import com.example.app.question.Question;
import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

import java.io.Serializable;
import java.util.List;

public class Questionnaire implements Serializable {

	// name of Questionnaire
	@SerializedName ("questionnaireName")
	private final String name;
	// list of all questions
	@SerializedName ("questions")
	private final List<Question> questionList;
	// path to the Questionnaire file
	@Expose (serialize = false, deserialize = false)
	private String path;

	// constructor only for java compiler reasons
	private Questionnaire () {
		name = null;
		questionList = null;
	}

	// getter
	public String getName () {
		return this.name;
	}

	public List<Question> getQuestionList () {
		return this.questionList;
	}

	public String getPath () {
		return this.path;
	}

	// setter (only needed for path)
	public void setPath (String path) {
		this.path = path;
	}
}
