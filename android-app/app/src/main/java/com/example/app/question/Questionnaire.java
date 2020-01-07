package com.example.app.question;

import android.support.annotation.Nullable;

import com.example.app.answer.Condition;
import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

import java.io.Serializable;
import java.util.Date;
import java.util.List;

public class Questionnaire implements Serializable {
	// id of Questionnaire
	@SerializedName("id") private final int id;
	
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
	
	// path to the Questionnaire file
	@Expose (serialize = false, deserialize = false)
	private String path;
	
	// list of conditions
	@SerializedName ("conditions")
	private final List<Condition> conditionList;
	
	// constructor only for java compiler reasons
	private Questionnaire () {
		name = null;
		questionList = null;
		id = -1;
		reminderList = null;
		conditionList = null;
		priority = 0;
		this.editTime = null;
	}
	
	// getter
	public String getName () {
		return name;
	}
	
	public int getID() {
		return id;
	}
	
	public int getPriority () {
		return priority;
	}
	
	public List<Question> getQuestionList () {
		return questionList;
	}
	
	public List<Date> getReminderList () {
		return reminderList;
	}
	
	public String getPath () {
		return path;
	}
	
	public List<Condition> getConditionList () {
		return conditionList;
	}
	
	@Nullable
	public String getEditTime() {
		return editTime;
	}
	
	
	// setter (only needed for path)
	public void setPath (String path) {
		this.path = path;
	}
}