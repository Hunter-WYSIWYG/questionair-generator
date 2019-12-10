package com.example.app.question;

import com.example.app.answer.Answer;
import com.example.app.answer.Condition;
import com.google.gson.annotations.SerializedName;

import java.util.List;

public class Note extends Question {
	@SerializedName ("minValue")
	public final String noteText;
	
	// constructor
<<<<<<< android-app/app/src/main/java/com/example/app/question/Note.java
	public Note(int id, String questionText, List<Answer> conditions, String text, String hint) {
		super (id, QuestionType.Note, conditions, text, hint);
=======
	public Note(int id, String questionText, List<Condition> conditions, String text) {
		super (id, QuestionType.Note, conditions, text);
>>>>>>> android-app/app/src/main/java/com/example/app/question/Note.java
		
		noteText = text;
	}
	
}
