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
	@SerializedName ("questionType")
	public final QuestionType type;
	
	@SerializedName ("id")
	public final int id;
	
	@SerializedName ("text")
	public final String questionText;
	
	@SerializedName ("hint")
	public final String hint;

	@SerializedName("editTime") 
	public final String editTime;
	
	// constructor
	public Question(int id, QuestionType type, String questionText, String hint) {
		this.id = id;
		this.type = type;
		this.questionText = questionText;
		this.hint = hint;
		this.editTime = null;
	}
}