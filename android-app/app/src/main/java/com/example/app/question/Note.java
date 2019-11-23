package com.example.app.question;

import com.example.app.answer.Answer;
import com.google.gson.annotations.SerializedName;

import java.util.Collections;
import java.util.List;

public class Note extends Question {
	@SerializedName ("minValue")
	public final String noteText;
	
	// constructor
	public Note (int id, String questionText, List<Answer> conditions, String text) {
		super (id, QuestionType.Note, conditions, text);
		
		this.noteText = text;
	}
	
}
