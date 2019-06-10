package com.example.app;

import com.google.gson.annotations.SerializedName;

public enum OptionType {
	@SerializedName("0")
	StaticText,
	@SerializedName("1")
	EnterText,
	@SerializedName("2")
	Slider
}
