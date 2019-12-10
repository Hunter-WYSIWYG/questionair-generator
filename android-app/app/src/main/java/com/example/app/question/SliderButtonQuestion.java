package com.example.app.question;

import com.example.app.answer.Answer;
import com.example.app.answer.Condition;
import com.google.gson.annotations.SerializedName;

import java.util.List;

public class SliderButtonQuestion extends Question {
	@SerializedName ("size")
	public final double size;
	@SerializedName ("leftIndex")
	public final String leftIndex;
	@SerializedName ("rightIndex")
	public final String rightIndex;
	
	//constructor
<<<<<<< android-app/app/src/main/java/com/example/app/question/SliderButtonQuestion.java
	public SliderButtonQuestion(int id, String questionText, List<Answer> conditions, int size, String leftIndex, String rightIndex, String hint) {
		super (id, QuestionType.SliderButton, conditions, questionText, hint);
=======
	public SliderButtonQuestion(int id, String questionText, List<Condition> conditions, int size, String leftIndex, String rightIndex) {
		super (id, QuestionType.SliderButton, conditions, questionText);
>>>>>>> android-app/app/src/main/java/com/example/app/question/SliderButtonQuestion.java
		
		this.size = size;
		this.leftIndex = leftIndex;
		this.rightIndex = rightIndex;
	}
}