package com.example.app.question;

import android.support.annotation.NonNull;

import com.google.gson.annotations.SerializedName;

import java.util.List;

public class ChoiceQuestion extends Question {
	// list of options, no matter if singleChoice or multipleChoice
	@SerializedName ("options")
	public final List<Option> options;
	
	// constructor
	private ChoiceQuestion(int id, QuestionType type, String questionText, List<Option> options) {
		super(id, type, questionText);
		this.options = options;
	}
	
	// ChoiceQuestion can only be MultipleChoice or SingleChoice
	@NonNull
	public static ChoiceQuestion createSingleChoice(int id, String questionText, List<Option> options) {
		return new ChoiceQuestion(id, QuestionType.SingleChoice, questionText, options);
	}

	@NonNull
	public static ChoiceQuestion createMultipleChoice(int id, String questionText, List<Option> options) {
		return new ChoiceQuestion(id, QuestionType.MultipleChoice, questionText, options);
	}
	
	// test if singleChoice
	public boolean isSingleChoice() {
		return type == QuestionType.SingleChoice;
	}

	@Override
	public int getAmountPossibleOutcomes() {
		// single choice -> as many as can be clicked
		// multiple choice -> any combination, either clicked/ not clicked -> 2^(amount of options)
		return type == QuestionType.SingleChoice ? options.size() : 1 << options.size();
	}
}
