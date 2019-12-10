package com.example.app.question;

import com.example.app.answer.Answer;
import com.example.app.answer.Condition;
import com.google.gson.annotations.SerializedName;

import java.util.List;

public class TableQuestion extends Question {
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
	public TableQuestion(int id, String questionText, List<Condition> conditions, int size, String topName, String bottomName, String rightName, String leftName) {
		super (id, QuestionType.Table, questionText);
		
		this.size = size;
		this.topName = topName;
		this.bottomName = bottomName;
		this.rightName = rightName;
		this.leftName = leftName;
	}
}