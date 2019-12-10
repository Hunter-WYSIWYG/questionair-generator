package com.example.app.question;

import com.example.app.answer.Answer;
import com.example.app.answer.Condition;
import com.google.gson.annotations.SerializedName;

import java.util.List;

public class ChoiceQuestion extends Question {
	// list of options, no matter if singleChoice or multipleChoice
	@SerializedName ("options")
	public final List<Option> options;

	// constructor
	private ChoiceQuestion (int id, QuestionType type, List<Condition> conditions, String questionText, List<Option> options,String hint) {
		super (id, type, conditions, questionText, hint);
		this.options = options;
	}

	// ChoiceQuestion can only be MultipleChoice or SingleChoice
	public static ChoiceQuestion createSingleChoice (int id, QuestionType type, List<Condition> conditions, String questionText, List<Option> options,String hint) {
		return new ChoiceQuestion (id, QuestionType.SingleChoice, conditions,  questionText, options, hint);
	}

	public static ChoiceQuestion createMultipleChoice (int id, QuestionType type, List<Condition> conditions, String questionText, List<Option> options,String hint) {
		return new ChoiceQuestion (id, QuestionType.MultipleChoice, conditions, questionText, options, hint);

	}

	// test if singleChoice
	public boolean isSingleChoice () {
		return type == QuestionType.SingleChoice;
	}
}
