package com.example.app.answer;

import com.example.app.question.Question;
import com.example.app.question.QuestionType;

import org.jetbrains.annotations.NotNull;

import java.io.Serializable;

public abstract class Answer implements Serializable {
	// TODO : EVERYTHING

	@NotNull
	private final QuestionType qType;
	private final int questionID;

	public Answer(@NotNull QuestionType givenQType, final int givenQuestionID) {
		qType = givenQType;
		questionID = givenQuestionID;
	}

	//this constructor should be preferred
	public Answer(@NotNull final Question question) {
		qType = question.type;
		questionID = question.id;
	}

	@NotNull
	public QuestionType getQType() {
		return qType;
	}

	public int getQuestionID() {
		return questionID;
	}

	// to know which branch need to be taken when adding conditions
	public abstract int getChosenOutcomeIdx();

	public String toString() {
		return "Answer(qID:" + questionID + ",qType:" + qType + ",outcome:" + getChosenOutcomeIdx() + ")";
	}
}
