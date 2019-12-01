package com.example.app.question;

import com.example.app.answer.Answer;
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
	public SliderButtonQuestion(int id, String questionText, List<Answer> conditions, int size, String leftIndex, String rightIndex) {
		super (id, QuestionType.SliderButton, conditions, questionText);
		
		this.size = size;
		this.leftIndex = leftIndex;
		this.rightIndex = rightIndex;
	}
}