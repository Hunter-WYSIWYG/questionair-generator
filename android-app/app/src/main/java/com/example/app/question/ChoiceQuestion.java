package com.example.app.question;

import com.example.app.answer.Answer;
import com.google.gson.annotations.SerializedName;

import java.util.List;

public class ChoiceQuestion extends Question {
	// list of options, no matter if singleChoice or multipleChoice
	@SerializedName ("options")
	public final List<Option> options;

	// constructor
	private ChoiceQuestion (int id, QuestionType type, List<Answer> conditions, String questionText, List<Option> options) {
		super (id, type, conditions, questionText);
		this.options = options;
	}

	// ChoiceQuestion can only be MultipleChoice or SingleChoice
	public static ChoiceQuestion createSingleChoice (int id, QuestionType type, List<Answer> conditions, String questionText, List<Option> options) {
		return new ChoiceQuestion (id, QuestionType.SingleChoice, conditions,  questionText, options);
	}

	public static ChoiceQuestion createMultipleChoice (int id, QuestionType type, List<Answer> conditions, String questionText, List<Option> options) {
		return new ChoiceQuestion (id, QuestionType.MultipleChoice, conditions, questionText, options);
	}

	// test if singleChoice
	public boolean isSingleChoice () {
		return this.type == QuestionType.SingleChoice;
	}
}
