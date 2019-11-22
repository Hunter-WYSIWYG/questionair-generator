package com.example.app.question;

import com.google.gson.annotations.JsonAdapter;
import com.google.gson.annotations.SerializedName;

import java.io.Serializable;


// Question uses id and type
@JsonAdapter (QuestionAdapter.class) // -> using QuestionAdapter to convert from or to JSON
public abstract class Question implements Serializable {
	
	// TODO : put conditions here?
	
	public static final String TYPE_JSON_NAME = "type";
	public final int id;
	@SerializedName (TYPE_JSON_NAME)
	public final QuestionType type;
	
	public final String questionText;
	
	// constructor
	Question(int id, QuestionType type, String questionText) {
		this.id = id;
		this.type = type;
		this.questionText = questionText;
	}
	
}

