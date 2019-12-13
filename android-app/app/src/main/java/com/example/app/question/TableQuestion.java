package com.example.app.question;

import com.example.app.answer.Answer;
import com.example.app.answer.Condition;
import com.google.gson.annotations.SerializedName;

import java.util.List;

public class TableQuestion extends Question {
	@SerializedName ("tableSize")
	public final double size;
	
	@SerializedName ("topText")
	public final String topName;
	
	@SerializedName ("bottomText")
	public final String bottomName;
	
	@SerializedName ("rightText")
	public final String rightName;
	
	@SerializedName ("leftText")
	public final String leftName;
	
	//constructor
	public TableQuestion(int id, String questionText, int size, String topName, String bottomName, String rightName, String leftName, String hint) {
		super (id, QuestionType.Table, questionText, hint);
		this.size = size;
		this.topName = topName;
		this.bottomName = bottomName;
		this.rightName = rightName;
		this.leftName = leftName;
	}
}