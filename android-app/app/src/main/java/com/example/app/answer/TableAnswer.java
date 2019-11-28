package com.example.app.answer;

import com.example.app.question.Question;
import com.google.gson.annotations.SerializedName;

import org.jetbrains.annotations.NotNull;

public class TableAnswer extends Answer {
	@SerializedName("chosenButtonId")
	private final int chosenButtonId;

	public TableAnswer(@NotNull final Question question, final int buttonId) {
		super(question);
		chosenButtonId = buttonId;
	}

	@Override
	public int getChosenOutcomeIdx() {
		return chosenButtonId;
	}

	public int getChosenButtonId() {
		return chosenButtonId;
	}
}
