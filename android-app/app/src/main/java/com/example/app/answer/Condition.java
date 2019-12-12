package com.example.app.answer;

import com.google.gson.annotations.SerializedName;

import java.io.Serializable;

public class Condition implements Serializable {
	@SerializedName("parent_id")
	public final int parentId;
	
	@SerializedName("child_id")
	public final int childId;
	
	@SerializedName("answer_id")
	public final int answerId;
	
	// constructor
	public Condition (int parentId, int childId, int answerId) {
		this.parentId = parentId;
		this.childId = childId;
		this.answerId = answerId;
	}
}