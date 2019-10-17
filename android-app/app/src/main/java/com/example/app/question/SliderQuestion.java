package com.example.app.question;

import java.util.Collections;
import java.util.List;

public class SliderQuestion extends Question {
	public final List<String> sliderValues;
	
	// constructor
	public SliderQuestion (int id, String questionText, List <String> sliderValues) {
		super (id, QuestionType.Slider, questionText);
		this.sliderValues = sliderValues;
	}
	// for testing only
	public String toString () {
		return "SliderQuestion { id=" + this.id + ", type=" + this.type + ", sliderValues=" + this.sliderValues.toString () + " }";
	}
}
