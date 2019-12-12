package com.example.app.question;

import com.example.app.answer.Condition;
import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

import java.io.Serializable;
import java.util.List;
import java.util.Date;

public class Questionnaire implements Serializable {
	// id of Questionnaire
	@SerializedName ("id")
	private final double id;
	
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
		this.id = 0.0;
		this.reminderList = null;
		this.conditionList = null;
		this.priority = 0;
	}
	
	// getter
	public String getName () {
		return this.name;
	}
	
	public double getID () {
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
	
	// setter (only needed for path)
	public void setPath (String path) {
		this.path = path;
	}
}