package com.example.app.question;

import android.os.Build;

import com.google.gson.annotations.SerializedName;

import java.io.Serializable;
import java.util.Objects;

public class Option implements Serializable {
	// the id of this option
	@SerializedName ("id")
	private final int id;
	
	 // the type of this option
	@SerializedName ("_type")
	private final OptionType type;
	
	 // text shown next to the button
	@SerializedName ("text")
	private final String optionText;

	// constructor
	public Option (int id, String optionText, OptionType type) {
		this.id = id;
		this.optionText = optionText;
		this.type = type;
	}
	
	// getters
	public Integer getId () {
		return this.id;
	}
	
	public String getOptionText () {
		return this.optionText;
	}
	
	public OptionType getType () {
		return this.type;
	}
}