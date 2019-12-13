package com.example.app.question;

import com.google.gson.annotations.SerializedName;

public enum OptionType {
	// clickable answer is static
	@SerializedName ("regular") StaticText,

	// answer is a text box
	@SerializedName ("free") EnterText
}