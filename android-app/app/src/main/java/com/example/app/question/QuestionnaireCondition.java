package com.example.app.question;

import com.google.gson.annotations.SerializedName;

import java.io.Serializable;

public class QuestionnaireCondition implements Serializable {
	@SerializedName("parent_id")
	private final int parent_id;
	@SerializedName("child_id")
	private final int child_id;
	@SerializedName("answer_id")
	private final int answer_id;
	
	public QuestionnaireCondition(){
		this.parent_id = -1;
		this.child_id = -1;
		this.answer_id = -1;
	}
	
	public QuestionnaireCondition(int parent_id, int child_id, int answer_id){
		this.parent_id = parent_id;
		this.child_id = child_id;
		this.answer_id = answer_id;
	}
	
	public int getParent_id() {
		return parent_id;
	}
	
	public int getChild_id() {
		return child_id;
	}
	
	public int getAnswer_id() {
		return answer_id;
	}
}
