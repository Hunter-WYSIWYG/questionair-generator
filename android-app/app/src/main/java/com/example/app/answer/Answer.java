package com.example.app.answer;

import com.google.gson.annotations.SerializedName;

import java.io.Serializable;

public class Answer implements Serializable {
	@SerializedName("_type")
	public final String type;
	@SerializedName("id")
	public final int id;
	@SerializedName("text")
	public final String text;
	@SerializedName("number")
	public final int number;
	
	
	public Answer(final String type, final int id, final String text, final int number) {
		this.type = type;
		this.id = id;
		this.text = text;
		this.number = number;
	}
	
	public String getType() {
		return type;
	}
	
	public Integer getId() {
		return id;
	}
	
	public String getText() {
		return text;
	}
	
	public int getNumber() {
		return number;
	}
	
}
