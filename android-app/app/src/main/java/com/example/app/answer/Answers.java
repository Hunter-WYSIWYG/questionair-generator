package com.example.app.answer;

import com.example.app.question.QuestionType;
import com.google.gson.annotations.SerializedName;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

public class Answers implements Serializable {
	@SerializedName("title_of_questionnaire")
	public final String title;
	@SerializedName("answerTime")
	public final Date time;
	@SerializedName("questionnaire_id")
	public final int qnaid;
	@SerializedName("type_of_question")
	public final QuestionType qType;
	@SerializedName("question_id")
	public final int qid;
	@SerializedName("question_text")
	public final String text;
	@SerializedName("answers")
	public List<Answer> chosenValues=new ArrayList<Answer>();

	public Answers() {
		title="";
		time = null;
		qType = null;
		qnaid=0;
		qid=0;
		text="";
		chosenValues = null;
	}
	
	public Answers(final String title, final Date time, final int qnaid, final QuestionType qType, final int qid, final String text, final List<Answer> chosenValue){
		this.title = title;
		this.time = time;
		this.qnaid = qnaid;
		this.qType = qType;
		this.qid = qid;
		this.text = text;
		this.chosenValues.addAll(chosenValue);
	};
	
	public String getTitle() {
		return title;
	}
	
	public Date getTime() {
		return time;
	}
	
	public int getQnaid() {
		return qnaid;
	}
	
	public QuestionType getqType() {
		return qType;
	}
	
	public int getQid() {
		return qid;
	}
	
	public String getText() {
		return text;
	}
	
	public List<Answer> getChosenValues() {
		return chosenValues;
	}
}
