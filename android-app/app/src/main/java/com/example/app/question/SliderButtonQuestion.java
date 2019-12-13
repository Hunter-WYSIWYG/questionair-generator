package com.example.app.question;

import com.example.app.answer.Answer;
import com.example.app.answer.Condition;
import com.google.gson.annotations.SerializedName;

import java.util.List;

public class SliderButtonQuestion extends Question {
	@SerializedName ("tableSize")
	public final double size;
	
	@SerializedName ("leftText")
	public final String leftIndex;
	
	@SerializedName ("rightText")
	public final String rightIndex;
	
	//constructor
	public SliderButtonQuestion(int id, String questionText, int size, String leftIndex, String rightIndex, String hint) {
		super (id, QuestionType.SliderButton, questionText, hint);
		this.size = size;
		this.leftIndex = leftIndex;
		this.rightIndex = rightIndex;
	}
}