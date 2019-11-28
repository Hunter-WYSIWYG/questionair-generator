package com.example.app.question;

import com.google.gson.annotations.JsonAdapter;
import com.google.gson.annotations.SerializedName;

import java.io.Serializable;


// Question uses id and type
@JsonAdapter(QuestionAdapter.class) // -> using QuestionAdapter to convert from or to JSON
public abstract class Question implements Serializable {
	@SerializedName("questionID")
	public final int id;
	@SerializedName("type")
	public final QuestionType type;

	public final String questionText;

	// constructor
	Question(int id, QuestionType type, String questionText) {
		this.id = id;
		this.type = type;
		this.questionText = questionText;
	}

	// at least as big as the branch count from this question, better would be making it as big as could occur, at least 1
	public abstract int getAmountPossibleOutcomes();
}

