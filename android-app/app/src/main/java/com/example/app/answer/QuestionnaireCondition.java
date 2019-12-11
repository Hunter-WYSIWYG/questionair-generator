package com.example.app.answer;

import java.io.Serializable;

public class QuestionnaireCondition implements Serializable {
	// class that helps converting condition list of questionnaire to list for questions
	private final int parent_id;
	private final int child_id;
	private final int answer_id;
	
	public QuestionnaireCondition() {
	
		parent_id = -1;
		child_id = -1;
		answer_id = -1;
		
	}
	
	public QuestionnaireCondition(int parent_id, int child_id, int answer_id) {
		
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