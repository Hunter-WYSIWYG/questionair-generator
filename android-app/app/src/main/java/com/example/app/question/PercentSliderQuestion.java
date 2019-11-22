package com.example.app.question;

import com.google.gson.annotations.SerializedName;

public class PercentSliderQuestion extends Question {
	@SerializedName ("minValue")
	private final double minValue;
	@SerializedName ("maxValue")
	private final double maxValue;
	@SerializedName ("stepSize")
	private final double stepSize;
	
	// constructor
	public PercentSliderQuestion(int id, String questionText, double minValue, double maxValue, double stepSize) {
		super(id, QuestionType.PercentSlider, questionText);
		
		if (minValue > maxValue)
			throw new IllegalArgumentException();
		
		// check if difference is multiple of stepSize
		double difference = maxValue - minValue;
		double modulo = difference % stepSize;
		if (modulo > 0.01 && modulo < difference - 0.01)
			throw new IllegalArgumentException();
		
		this.minValue = minValue;
		this.maxValue = maxValue;
		this.stepSize = stepSize;
	}

	@Override
	public int getAmountPossibleOutcomes() {
		return 1;
	}
}
