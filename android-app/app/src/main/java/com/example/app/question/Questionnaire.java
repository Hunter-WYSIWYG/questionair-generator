package com.example.app.question;

import android.support.annotation.Nullable;

import com.example.app.answer.Condition;
import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

import java.io.Serializable;
import java.util.List;
import java.util.Date;

public class Questionnaire implements Serializable {
	// id of Questionnaire
	@SerializedName ("id")
	private final int id;
	
	// name of Questionnaire
	@SerializedName ("title")
	private final String name;
	
	// priority of Questionnaire
	@SerializedName ("priority")
	private final int priority;
	
	// list of all questions
	@SerializedName ("elements")
	private final List<Question> questionList;
	
	// list of all reminders
	@SerializedName ("reminderTimes")
	private final List<Date> reminderList;
	
	@SerializedName("editTime")
	@Nullable
	private final String editTime;

	@SerializedName("viewingTime")
	private final String viewingTime;
	
	// path to the Questionnaire file
	@Expose (serialize = false, deserialize = false)
	private String path;
	
	// list of conditions
	@SerializedName ("conditions")
	private final List<Condition> conditionList;
	
	// constructor only for java compiler reasons
	private Questionnaire () {
		this.name = null;
		this.questionList = null;
		this.id = -1;
		this.reminderList = null;
		this.conditionList = null;
		this.priority = 0;
		this.editTime = null;
		this.viewingTime = null;
	}
	
	// getter
	public String getName () {
		return this.name;
	}
	
	public int getID () {
		return this.id;
	}
	
	public int getPriority () {
		return this.priority;
	}
	
	public List<Question> getQuestionList () {
		return this.questionList;
	}
	
	public List<Date> getReminderList () {
		return this.reminderList;
	}
	
	public String getPath () {
		return this.path;
	}
	
	public List<Condition> getConditionList () {
		return this.conditionList;
	}
	
	@Nullable
	public String getEditTime() {
		return editTime;
	}

	public String getViewingTime () {
		return this.viewingTime;
	}
	
	
	// setter (only needed for path)
	public void setPath (String path) {
		this.path = path;
	}
}