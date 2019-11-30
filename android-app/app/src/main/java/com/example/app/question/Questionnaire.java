package com.example.app.question;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

import org.jetbrains.annotations.Nullable;

import java.io.Serializable;
import java.util.List;

public class Questionnaire implements Serializable {
	// name of Questionnaire
	@Nullable
	@SerializedName("questionnaireName")
	private final String name;

	// if of Questionnaire
	@SerializedName("questionnaireID")
	private final int id;

	// list of all questions
	@Nullable
	@SerializedName("questions")
	private final List<Question> questionList;

	// list of all reminders
	@Nullable
	@SerializedName("reminderTimes")
	private final List<Reminder> reminderList;

	@SerializedName("editTime")
	@Nullable
	private final String editTime;

	// path to the Questionnaire file
	@Expose(serialize = false, deserialize = false)
	private String path;

	// constructor only for java compiler reasons
	private Questionnaire() {
		name = null;
		questionList = null;
		id = -1;
		reminderList = null;
		editTime = null;
	}

	// getter
	@Nullable
	public String getName() {
		return name;
	}

	public int getID() {
		return id;
	}

	@Nullable
	public List<Question> getQuestionList() {
		return questionList;
	}

	@Nullable
	public List<Reminder> getReminderList() {
		return reminderList;
	}

	public String getPath() {
		return path;
	}

	// setter (only needed for path)
	public void setPath(String path) {
		this.path = path;
	}

	@Nullable
	public String getEditTime() {
		return editTime;
	}
}
