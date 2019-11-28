package com.example.app.answer;

import com.example.app.question.Question;
import com.google.gson.annotations.SerializedName;

import org.jetbrains.annotations.NotNull;

import java.io.Serializable;

public class Answer implements Serializable {
	@SerializedName("_type")
	public final String type;
	@SerializedName("id")
	public final int id;
	@SerializedName("text")
	public final String text;
	
	public Answer(final String type, final int id, final String text) {
		this.type = type;
		this.id = id;
		this.text = text;
	}

	//this constructor should be preferred
	public Answer(@NotNull final Question question) {
		qType = question.type;
		questionID = question.id;
	
	public String getType() {
		return type;
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
	
	public Integer getId() {
		return id;
	}
	
	public String getText() {
		return text;
	}
	
	
}
