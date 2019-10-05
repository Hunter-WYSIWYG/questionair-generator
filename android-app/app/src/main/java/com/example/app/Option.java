package com.example.app;

import android.os.Build;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

import java.io.Serializable;
import java.util.List;
import java.util.Objects;

public class Option implements Serializable {
	
	/**
	 * number to identify option in a question
	 * <p>
	 * should ideally be unique in each question
	 * <p>
	 * Integer is used to allow for null as an error value, speed is of no concern anyway
	 */
	@SerializedName("answerID")
	@Expose
	private final Integer id;
	
	/**
	 * the type of this option
	 */
	@Expose
	@SerializedName("answerType")
	private final OptionType type;
	
	/**
	 * text shown next to the button, or on top of the slider
	 */
	@SerializedName("answerText")
	@Expose
	private final String answerText;
	
	/**
	 * text shown under the slider depending on its position
	 */
	@SerializedName("sliderExtraText")
	@Expose
	private final List<String> extraText;
	
	/**
	 * constructor for static or prose text options
	 */
	public Option(int id, String answerText, OptionType type) {
		if (type == OptionType.Slider) {
			throw new IllegalStateException("Type was " + type + ", this is not allowed in this constructor.");
		}
		this.id = id;
		this.answerText = answerText;
		this.type = type;
		extraText = null;
	}
	
	/**
	 * constructor for static or prose text options
	 */
	public Option(int id, String answerText, List<String> sliderTexts) {
		this.id = id;
		this.answerText = answerText;
		type = OptionType.Slider;
		extraText = sliderTexts;
	}
	
	/**
	 * getters
	 */
	public Integer getId() {
		return id;
	}
	
	public String getAnswerText() {
		return answerText;
	}
	
	public OptionType getType() {
		return type;
	}
	
	public List<String> getSliderExtraText() {
		return extraText;
	}
	
	@Override
	public int hashCode() {
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
			return Objects.hash(id, type, answerText, extraText);
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
			return Objects.equals(id, option.id) && type == option.type && Objects.equals(answerText, option.answerText) && Objects.equals(extraText, option.extraText);
		}
		//TODO
		throw new IllegalStateException("insufficient api level");
	}
}