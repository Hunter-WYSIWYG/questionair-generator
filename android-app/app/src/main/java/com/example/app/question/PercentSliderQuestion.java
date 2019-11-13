package com.example.app.question;

import com.google.gson.annotations.SerializedName;

public class PercentSliderQuestion extends Question {
	@SerializedName ("minValue")
	public final double minValue;
	@SerializedName ("maxValue")
	public final double maxValue;
	@SerializedName ("stepSize")
	public final double stepSize;
	
	// constructor
	public PercentSliderQuestion (int id, String questionText, double minValue, double maxValue, double stepSize) {
		super (id, QuestionType.PercentSlider, questionText);
		
		if (minValue > maxValue)
			throw new IllegalArgumentException ();
		
		// check if difference is multiple of stepSize
		double difference = maxValue - minValue;
		double modulo = difference % stepSize;
		if (modulo > 0.01 && modulo < difference - 0.01)
			throw new IllegalArgumentException ();
		
		this.minValue = minValue;
		this.maxValue = maxValue;
		this.stepSize = stepSize;
	}
	
}
