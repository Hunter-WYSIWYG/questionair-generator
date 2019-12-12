package com.example.app.question;

import com.google.gson.annotations.SerializedName;
import java.io.Serializable;

public class SliderOption implements Serializable {
	@SerializedName("id")
	private final int id;
	
	@SerializedName ("text")
	private final String optionText;
	
	// constructor
	public SliderOption (int id, String optionText) {
		this.id = id;
		this.optionText = optionText;
	}
	
	// getters
	public int getId () {
		return this.id;
	}
	
	public String getOptionText () {
		return this.optionText;
	}
}