package com.example.app.question;

import com.google.gson.annotations.SerializedName;

public enum QuestionType {
	@SerializedName ("singleChoice") SingleChoice,

	@SerializedName ("multipleChoice") MultipleChoice,

	@SerializedName ("slider") Slider,
	
	@SerializedName ("percentslider") percentSlider,
	
	@SerializedName ("note") Note
}

