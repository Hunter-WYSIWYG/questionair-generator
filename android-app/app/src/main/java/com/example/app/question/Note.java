package com.example.app.question;

import com.google.gson.annotations.SerializedName;

public class Note extends Question {
	//TODO : rename this in the JSON
	@SerializedName ("minValue")
	private final String noteText;
	
	// constructor
	public Note(int id, String questionText, String text) {
		super(id, QuestionType.Note, text);
		
		this.noteText = text;
	}
	
}
