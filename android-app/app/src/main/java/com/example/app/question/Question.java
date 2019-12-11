package com.example.app.question;

import com.example.app.answer.Condition;
import com.example.app.answer.QuestionnaireCondition;
import com.google.gson.annotations.JsonAdapter;
import com.google.gson.annotations.SerializedName;

import java.io.Serializable;
import java.lang.reflect.Array;
import java.util.ArrayList;
import java.util.List;


// Question uses id and type
@JsonAdapter (QuestionAdapter.class) // -> using QuestionAdapter to convert from or to JSON
public abstract class Question implements Serializable {
	
	public final int questionID;
	
	public static final String TYPE_JSON_NAME = "type";
	@SerializedName (TYPE_JSON_NAME)
	public final QuestionType type;
	
	public List<Condition> conditions;
	
	public final String questionText;
	
	@SerializedName("editTime") 
	public final String editTime;
	
	public final String hint;
	
	// constructor
	public Question(int id, QuestionType type, String questionText, String hint) {
		this.questionID = id;
		this.type = type;
		// this.conditions = conditions;
		this.conditions = new ArrayList<>();
		this.questionText = questionText;
		this.editTime = null;
		this.hint = hint;
	}
	
	
	
	
}

