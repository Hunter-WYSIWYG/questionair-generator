package com.example.app.question;

import com.example.app.answer.Answer;
import com.google.gson.annotations.SerializedName;

import java.util.List;

public class PercentSliderQuestion extends Question {
	@SerializedName ("rightText")
	public final String rightText;
	
	@SerializedName ("leftText")
	public final String leftText;
	
	// constructor
	public PercentSliderQuestion (int id, String questionText, String leftText, String rightText, String hint) {
		super (id, QuestionType.PercentSlider, questionText, hint);
		this.leftText = leftText;
		this.rightText = rightText;
	}
}