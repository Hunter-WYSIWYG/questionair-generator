package com.example.app.question;

import com.google.gson.annotations.SerializedName;

public class SliderButtonQuestion extends Question {
	@SerializedName ("size")
	public final double size;
	@SerializedName ("leftIndex")
	public final String leftIndex;
	@SerializedName ("rightIndex")
	public final String rightIndex;
	
	//constructor
	public SliderButtonQuestion (int id, String questionText, int size, String leftIndex, String rightIndex) {
		super (id, QuestionType.SliderButton, questionText);
		
		this.size = size;
		this.leftIndex = leftIndex;
		this.rightIndex = rightIndex;
	}
	
	@Override
	public int getAmountPossibleOutcomes() {
		return 1;
	}
}