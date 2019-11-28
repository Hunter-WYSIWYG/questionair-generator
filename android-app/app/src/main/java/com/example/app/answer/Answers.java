package com.example.app.answer;

import com.example.app.question.Questionnaire;
import com.google.gson.annotations.SerializedName;

import org.jetbrains.annotations.NotNull;

import java.io.Serializable;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

public class Answers implements Serializable {
	@SerializedName("title_of_questionnaire")
	private final String title;

	@SerializedName("answerTime")
	private final Date time;

	@SerializedName("questionnaire_id")
	private final int qnId;

	@SerializedName("answers")
	private final List<Answer> answersList;

	public Answers(@NotNull final Questionnaire questionnaire, @NotNull final List<Answer> answersList) {
		title = questionnaire.getName();
		time = Calendar.getInstance().getTime();
		qnId = questionnaire.getID();
		this.answersList = answersList;
	}

	public String getTitle() {
		return title;
	}

	public Date getTime() {
		return time;
	}

	public int getQnId() {
		return qnId;
	}

	public List<Answer> getAnswersList() {
		return answersList;
	}
}
