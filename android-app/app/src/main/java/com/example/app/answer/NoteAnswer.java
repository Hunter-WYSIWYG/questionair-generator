package com.example.app.answer;

import com.example.app.question.Question;

import org.jetbrains.annotations.NotNull;

public class NoteAnswer extends Answer {
	public NoteAnswer(@NotNull final Question question) {
		super(question);
	}

	@Override
	public int getChosenOutcomeIdx() {
		return 0;
	}
}
