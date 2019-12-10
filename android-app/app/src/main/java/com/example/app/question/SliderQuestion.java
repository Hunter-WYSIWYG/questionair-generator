package com.example.app.question;

import com.example.app.answer.Answer;
import com.example.app.answer.Condition;
import com.google.gson.annotations.SerializedName;

import java.util.List;

public class SliderQuestion extends Question {
	@SerializedName ("minValue")
	public final double minValue;
	@SerializedName ("maxValue")
	public final double maxValue;
	@SerializedName ("stepSize")
	public final double stepSize;
	@SerializedName ("leftText")
	public final String leftText;
	@SerializedName ("rightText")
	public final String rightText;
	

	// constructor
<<<<<<< android-app/app/src/main/java/com/example/app/question/SliderQuestion.java
	public SliderQuestion(int id, String questionText, List<Answer> conditions, double minValue, double maxValue, double stepSize, String leftText, String rightText,String hint) {
		super (id, QuestionType.Slider, conditions, questionText, hint);
=======
	public SliderQuestion(int id, String questionText, List<Condition> conditions, double minValue, double maxValue, double stepSize) {
		super (id, QuestionType.Slider, conditions, questionText);
>>>>>>> android-app/app/src/main/java/com/example/app/question/SliderQuestion.java
		
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
		this.leftText = leftText;
		this.rightText = rightText;
	}
	
}
