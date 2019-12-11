package com.example.app.question;

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
	public SliderButtonQuestion(int id, String questionText, int size, String leftIndex, String rightIndex, String hint) {
		super (id, QuestionType.SliderButton, questionText, hint);
		
		this.size = size;
		this.leftIndex = leftIndex;
		this.rightIndex = rightIndex;
	}
}