package com.example.app.question;

import com.example.app.answer.Answer;
import com.google.gson.annotations.SerializedName;

import java.util.List;

public class Note extends Question {
	// constructor
	public Note (int id, String text, String hint) {
		super (id, QuestionType.Note, text, hint);
	}
}
