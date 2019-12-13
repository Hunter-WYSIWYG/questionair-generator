package com.example.app.answer;

import com.example.app.question.QuestionType;
import com.google.gson.annotations.SerializedName;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class AnswerCollection implements Serializable {
	@SerializedName("title_of_questionnaire")
	public final String title;
	
	@SerializedName("answerTime")
	public final Date questionnaireAnswerTime;
	
	@SerializedName("questionnaire_id")
	public final int questionnaireId;
	
	@SerializedName("type_of_question")
	public final QuestionType questionType;
	
	@SerializedName("question_id")
	public final int questionId;
	
	@SerializedName("question_text")
	public final String text;
	
	@SerializedName("answers")
	public List<Answer> answerList = new ArrayList<Answer> ();

	// constructor
	public AnswerCollection (final String title, final Date questionnaireAnswerTime, final int questionnaireId, final QuestionType questionType, final int questionId, final String text, final List<Answer> answerList) {
		this.title = title;
		this.questionnaireAnswerTime = questionnaireAnswerTime;
		this.questionnaireId = questionnaireId;
		this.questionType = questionType;
		this.questionId = questionId;
		this.text = text;
		this.answerList.addAll (answerList);
	}
	
	// getter
	public String getTitle () {
		return title;
	}
	
	public Date getQuestionnaireAnswerTime () {
		return questionnaireAnswerTime;
	}
	
	public int getQuestionnaireId () {
		return questionnaireId;
	}
	
	public QuestionType getQuestionType () {
		return questionType;
	}
	
	public int getQuestionId () {
		return questionId;
	}
	
	public String getText () {
		return text;
	}
	
	public List<Answer> getAnswerList () {
		return answerList;
	}
}