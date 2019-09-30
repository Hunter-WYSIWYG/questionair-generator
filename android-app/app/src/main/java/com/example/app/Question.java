package com.example.app;

import com.google.gson.annotations.SerializedName;

import java.io.Serializable;
import java.util.List;

public class Question implements Serializable {
	/**
	 * number to identify option in a question
	 * <p>
	 * should ideally be unique in each question
	 * <p>
	 * Integer is used to allow for null as an error value, speed is of no concern anyway
	 */
	@SerializedName("questionID")
	private final Integer id;
	
	/**
	 * string of the question
	 */
	@SerializedName("questionTitle")
	private final String title;
	
	/**
	 * list of options below the text
	 */
	@SerializedName("answers")
	private final List<Option> optionList;
	
	/**
	 * type, whether choose one or multiple
	 */
	@SerializedName("type")
	private final QuestionType type;
	
	/**
	 * constructor used for (probably) everything
	 */
	public Question(int id, String title, List<Option> optionList, QuestionType type) {
		this.id = id;
		this.title = title;
		this.optionList = optionList;
		this.type = type;
	}
	
	/**
	 * getters
	 */
	public Integer getId() {
		return id;
	}
	
	public String getTitle() {
		return title;
	}
	
	public List<Option> getOptionList() {
		return optionList;
	}
	
	public QuestionType getType() {
		return type;
	}
	
}
