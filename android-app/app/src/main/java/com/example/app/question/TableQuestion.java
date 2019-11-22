package com.example.app.question;

import com.google.gson.annotations.SerializedName;

public class TableQuestion extends Question {
	// TODO : make this an int
	@SerializedName ("size")
	public final double size;
	@SerializedName ("topName")
	public final String topName;
	@SerializedName ("bottomName")
	public final String bottomName;
	@SerializedName ("rightName")
	public final String rightName;
	@SerializedName ("leftName")
	public final String leftName;
	
	//constructor
	public TableQuestion(int id, String questionText, int size, String topName, String bottomName, String rightName, String leftName) {
		super(id, QuestionType.Table, questionText);
		
		this.size = size;
		this.topName = topName;
		this.bottomName = bottomName;
		this.rightName = rightName;
		this.leftName = leftName;
	}
}