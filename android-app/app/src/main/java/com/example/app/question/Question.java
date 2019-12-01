package com.example.app.question;

import com.example.app.answer.Answer;
import com.google.gson.*;
import com.google.gson.annotations.JsonAdapter;
import com.google.gson.annotations.SerializedName;

import java.io.Serializable;


// Question uses id and type
@JsonAdapter (QuestionAdapter.class) // -> using QuestionAdapter to convert from or to JSON
public abstract class Question implements Serializable {
	
	public final int questionID;
	
	public static final String TYPE_JSON_NAME = "type";
	@SerializedName (TYPE_JSON_NAME)
	public final QuestionType type;
	
	public final List<Answer> conditions;
	
	public final String questionText;
	
	// constructor
	public Question (int id, QuestionType type, List<Answer> conditions, String questionText) {
		this.questionID = id;
		this.type = type;
		this.conditions = conditions;
		this.questionText = questionText;
	}
	
	
}

