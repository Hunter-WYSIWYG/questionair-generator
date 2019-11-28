package com.example.app.answer;

import com.example.app.question.Question;
import com.google.gson.annotations.SerializedName;

import org.jetbrains.annotations.NotNull;

public class SingleChoiceAnswer extends Answer {
	@SerializedName("chosenId")
	private final int chosenOutcomeId;

	public SingleChoiceAnswer(@NotNull final Question question, final int outcomeId) {
		super(question);
		chosenOutcomeId = outcomeId;
	}

	@Override
	public int getChosenOutcomeIdx() {
		return chosenOutcomeId;
	}

	public int getChosenOutcomeId() {
		return chosenOutcomeId;
	}
}
