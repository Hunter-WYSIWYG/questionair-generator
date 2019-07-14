package com.example.app;

import com.google.gson.annotations.SerializedName;

public enum QuestionType {
	@SerializedName("0") SingleChoice, @SerializedName("1") MultipleChoice, @SerializedName("2") Slider
}
