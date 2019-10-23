package com.example.app.question;

import com.google.gson.annotations.SerializedName;

import java.util.Collections;
import java.util.List;

public class Note extends Question {
	@SerializedName ("minValue")
	public final String noteText;
	
	// constructor
	public Note (int id, String questionText, String text) {
		super (id, QuestionType.Note, text);
		
		this.noteText = text;
	}
	
}
