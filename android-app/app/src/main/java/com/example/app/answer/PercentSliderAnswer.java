package com.example.app.answer;

import com.example.app.question.Question;
import com.google.gson.annotations.SerializedName;

import org.jetbrains.annotations.NotNull;

public class PercentSliderAnswer extends Answer {
	@SerializedName("progressFloat")
	private final float chosenFloat;

	public PercentSliderAnswer(@NotNull final Question question, final float chosenValue) {
		super(question);
		chosenFloat = chosenValue;
	}

	@Override
	public int getChosenOutcomeIdx() {
		return 0;
	}

	public float getChosenFloat() {
		return chosenFloat;
	}
}
