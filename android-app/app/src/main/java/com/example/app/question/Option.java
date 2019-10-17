package com.example.app.question;

import android.os.Build;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

import java.io.Serializable;
import java.util.List;
import java.util.Objects;

public class Option implements Serializable {
	

	@SerializedName("answerID")
	private final Integer id;
	
	/**
	 * the type of this option
	 */
	@SerializedName("answerType")
	private final OptionType type;
	
	/**
	 * text shown next to the button
	 */
	@SerializedName("answerText")
	private final String answerText;
	

	public Option(int id, String answerText, OptionType type) {
		this.id = id;
		this.answerText = answerText;
		this.type = type;
	}
	
	
	// getters
	public Integer getId() {
		return id;
	}
	public String getAnswerText() {
		return answerText;
	}
	public OptionType getType() {
		return type;
	}
	
	
	@Override
	public int hashCode() {
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
			return Objects.hash(id, type, answerText);
		}
		//TODO
		throw new IllegalStateException("insufficient api level");
	}
	
	@Override
	public boolean equals(final Object o) {
		if (this == o)
			return true;
		if (o == null || getClass() != o.getClass())
			return false;
		final Option option = (Option) o;
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
			return Objects.equals(id, option.id) && type == option.type && Objects.equals(answerText, option.answerText);
		}
		//TODO
		throw new IllegalStateException("insufficient api level");
	}
}