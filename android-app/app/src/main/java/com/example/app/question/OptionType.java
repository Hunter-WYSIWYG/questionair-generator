package com.example.app.question;

import com.google.gson.annotations.SerializedName;

public enum OptionType {
	// clickable answer is static
	@SerializedName ("text") StaticText,
	
	// answer is a text box
	@SerializedName ("textbox") EnterText
}
