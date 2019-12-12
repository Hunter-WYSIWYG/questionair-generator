package com.example.app.question;

import com.example.app.answer.Answer;
import com.google.gson.annotations.SerializedName;

import java.util.List;

public class SliderQuestion extends Question {
	@SerializedName ("leftText")
	public final String leftText;
	
	@SerializedName ("rightText")
	public final String rightText;
	
	@SerializedName ("answers")
	public final List<SliderOption> sliderSteps;
	
	// constructor
	public SliderQuestion(int id, QuestionType type, List<SliderOption> sliderSteps, String questionText, double minValue, double maxValue, double stepSize, String leftText, String rightText, String hint) {
		super (id, type, questionText, hint);
		this.sliderSteps = sliderSteps;
		this.leftText = leftText;
		this.rightText = rightText;
	}
}