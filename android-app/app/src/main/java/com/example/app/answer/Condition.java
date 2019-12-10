package com.example.app.answer;

import com.google.gson.annotations.SerializedName;

import java.io.Serializable;

public class Condition implements Serializable {
	@SerializedName("qId")
	public final int qid;
	@SerializedName("chosenValue")
	public final int cv;
	
	public Condition(){
		qid=-1;
		cv=-1;
		
	}
	public Condition(int id,int val){
		qid=id;
		cv=val;
		
		
	}
}
