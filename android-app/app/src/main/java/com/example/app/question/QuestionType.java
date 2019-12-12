package com.example.app.question;

import com.google.gson.annotations.SerializedName;

public enum QuestionType {
	@SerializedName ("Single Choice") SingleChoice,

	@SerializedName ("Ja/Nein Frage") BinaryChoice,

	@SerializedName ("Multiple Choice") MultipleChoice,

	@SerializedName ("Skaliert unipolar") UnipolarSlider,
	
	@SerializedName ("Skaliert bipolar") BipolarSlider,
	
	@SerializedName ("Prozentslider") PercentSlider,
	
	@SerializedName ("Notiz") Note,
	
	@SerializedName ("Raster-Auswahl") Table,
	
	@SerializedName ("Button Slider") SliderButton,
}