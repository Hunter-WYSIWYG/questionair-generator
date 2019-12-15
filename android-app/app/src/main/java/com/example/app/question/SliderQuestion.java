package com.example.app.question;

import com.example.app.answer.Answer;
import com.example.app.answer.Condition;
import com.google.gson.annotations.SerializedName;

import java.util.List;

public class SliderQuestion extends Question {
	@SerializedName ("leftText")
	public final String leftText;
	
	@SerializedName ("rightText")
	public final String rightText;
	
	@SerializedName ("polarMin")
	public final int polarMin;
	
	@SerializedName ("polarMax")
	public final int polarMax;
	
	// constructor
	public SliderQuestion(int id, QuestionType type, int polarMin, int polarMax, String questionText, double minValue, double maxValue, double stepSize, String leftText, String rightText, String hint) {
		super (id, type, questionText, hint);
		this.polarMin = polarMin;
		this.polarMax = polarMax;
		this.leftText = leftText;
		this.rightText = rightText;
	}
}