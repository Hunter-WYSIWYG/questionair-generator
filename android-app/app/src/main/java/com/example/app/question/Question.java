package com.example.app.question;

import com.example.app.answer.Answer;
import com.example.app.answer.Condition;
import com.google.gson.*;
import com.google.gson.annotations.JsonAdapter;
import com.google.gson.annotations.SerializedName;

import java.io.Serializable;
import java.util.List;


// Question uses id and type
@JsonAdapter (QuestionAdapter.class) // -> using QuestionAdapter to convert from or to JSON
public abstract class Question implements Serializable {
	
	public final int id;
	
	public static final String TYPE_JSON_NAME = "type";
	@SerializedName (TYPE_JSON_NAME)
	public final QuestionType type;
	
	public final List<Condition> conditions;
	
	public final String questionText;
	
	public final String hint;
	
	// constructor
	public Question(int id, QuestionType type, List<Condition> conditions, String questionText, String hint) {
		this.id = id;
		this.type = type;
		this.questionText = questionText;
		this.conditions = conditions;
		this.hint = hint;
	}
	
	
}
