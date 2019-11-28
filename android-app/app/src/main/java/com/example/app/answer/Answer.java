package com.example.app.answer;

import com.example.app.question.Question;
import com.example.app.question.QuestionType;
import com.google.gson.annotations.SerializedName;

import org.jetbrains.annotations.NotNull;

import java.io.Serializable;
import java.util.Calendar;
import java.util.Date;

public abstract class Answer implements Serializable {
	@SerializedName("answerTime")
	private final Date time;

	@SerializedName("questionType")
	private final QuestionType qType;

	@SerializedName("id")
	private final int id;

	//this constructor should be preferred
	public Answer(@NotNull final Question question) {
		qType = question.type;
		id = question.id;
		time = Calendar.getInstance().getTime();
	}

	// to know which branch need to be taken when adding conditions
	public abstract int getChosenOutcomeIdx();

	public String toString() {
		return "Answer(qID:" + id + ",qType:" + qType + ",outcome:" + getChosenOutcomeIdx() + ")";
	}

	public int getId() {
		return id;
	}

	public Date getTime() {
		return time;
	}

	public QuestionType getQType() {
		return qType;
	}
}

