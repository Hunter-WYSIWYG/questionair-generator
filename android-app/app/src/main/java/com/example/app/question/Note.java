package com.example.app.question;

import com.example.app.answer.Answer;
import com.example.app.answer.Condition;
import com.google.gson.annotations.SerializedName;

import java.util.List;

public class Note extends Question {
	@SerializedName ("minValue")
	public final String noteText;
	
	// constructor
	public Note(int id, String questionText, List<Condition> conditions, String text, String hint) {
		super (id, QuestionType.Note, conditions, text, hint);
		noteText = text;
	}
	
}
