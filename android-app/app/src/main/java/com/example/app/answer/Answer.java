package com.example.app.answer;

import com.example.app.question.QuestionType;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

public class Answer implements Serializable {
	@SerializedName("_type")
	public final String type;
	
	@SerializedName("id")
	public final int id;
	
	@SerializedName("text")
	public final String text;
	
	// constructor	
	public Answer (final String type, final int id, final String text) {
		this.type = type;
		this.id = id;
		this.text = text;
	}
	
	// getter
	public String getType() {
		return this.type;
	}
	
	public Integer getId() {
		return this.id;
	}
	
	public String getText() {
		return this.text;
	}
}