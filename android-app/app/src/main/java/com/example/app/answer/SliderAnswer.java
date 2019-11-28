package com.example.app.answer;

import com.example.app.question.Question;
import com.google.gson.annotations.SerializedName;

import org.jetbrains.annotations.NotNull;

public class SliderAnswer extends Answer {
	@SerializedName("barProgress")
	private final int progress;

	public SliderAnswer(@NotNull final Question question, final int value) {
		super(question);
		progress = value;
	}

	public int getProgress() {
		return progress;
	}

	@Override
	public int getChosenOutcomeIdx() {
		return 0;
	}
}
