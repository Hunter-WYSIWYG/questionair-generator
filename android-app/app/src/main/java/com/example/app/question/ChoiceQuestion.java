package com.example.app.question;

import com.example.app.answer.Answer;
import com.google.gson.annotations.SerializedName;

import java.util.List;

public class ChoiceQuestion extends Question {
	// list of options, no matter if singleChoice or multipleChoice
	@SerializedName ("answers")
	public final List<Option> options;

	// constructor
	private ChoiceQuestion (int id, QuestionType type, String questionText, List<Option> options, String hint) {
		super (id, type, questionText, hint);
		this.options = options;
	}

	// test if singleChoice
	public boolean isSingleChoice () {
		return this.type == QuestionType.SingleChoice;
	}
}