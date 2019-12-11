package com.example.app;

import com.example.app.answer.Answer;
import com.example.app.answer.Condition;
import com.example.app.question.Question;
import com.example.app.question.Questionnaire;
import com.google.gson.annotations.SerializedName;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

// current state of questionnaire with answers
public class QuestionnaireState implements Serializable {
	@SerializedName("questionnaire")
	private final Questionnaire questionnaire;
	@SerializedName("answers")
	private final List<Answer> answers = new ArrayList<>();
	@SerializedName("conditions")
	private final List<Condition> conditions = new ArrayList<>();
	@SerializedName("endTime")
	private final Date endTime;
	@SerializedName("currentIndex")
	private int currentIndex;
	private long currentQuestionEndTime;
	
	// constructor, creates a new QuestionnaireState that starts at the first question
	public QuestionnaireState(Questionnaire questionnaire) {
		this.questionnaire = questionnaire;
		currentIndex = 0;
		
		goToNextPossibleQuestion();
		
		
		// TODO: comment this part
		final String editTime = questionnaire.getEditTime();
		if (editTime != null) {
			final String[] parts = editTime.split(":");
			endTime = new Date(System.currentTimeMillis() + 60000 * Long.parseLong(parts[0]) + 1000 * Long.parseLong(parts[1]));
		} else {
			endTime = null;
		}
		currentQuestionEndTime = 0L;
	}
	
	// goes to next question, skip zero or more questions if necessary (conditions)
	private void goToNextPossibleQuestion() {
		if (!this.isFinished() && !this.isCurrentQuestionPossible()) {
			this.currentIndex++;
			this.goToNextPossibleQuestion();
		}
	}
	
	// next button clicked -> current question answered and go to next question
	public void currentQuestionAnswered(List<Answer> answerList, List<Condition> conditionList) {
		// this.answers.addAll(answerList);
		this.conditions.addAll(conditionList);
		this.currentIndex++;
		this.goToNextPossibleQuestion();
	}
	
	// return true if there is no question left
	public boolean isFinished() {
		return currentIndex >= questionnaire.getQuestionList().size();
	}
	
	// test conditions and see if you can display this question
	private boolean isCurrentQuestionPossible() {
		
		// if all conditions of the question are met in the condition list, return true
		return this.conditions.containsAll(this.questionnaire.getQuestionList().get(currentIndex).conditions);
	
	}
	
	// getter
	public int getCurrentIndex() {
		return currentIndex;
	}
	
	public Questionnaire getQuestionnaire() {
		return questionnaire;
	}
	
	public Question getCurrentQuestion() {
		final Question q = questionnaire.getQuestionList().get(currentIndex);
		if (q.editTime != null) {
			final String[] parts = q.editTime.split(":");
			currentQuestionEndTime = System.currentTimeMillis() + 60000 * Long.parseLong(parts[0]) + 1000 * Long.parseLong(parts[1]);
		}
		return q;
	}
	
	public List<Condition> getConditions() {
		return this.conditions;
	}
	
	public List<Answer> getAnswers() {
		return this.answers;
	}
	
	public Date getEndTime() {
		return endTime;
	}
	
	public long getCurrentQuestionEndTime() {
		return currentQuestionEndTime;
	}
	
	// TODO: method saveCurrentState
	// TODO: to save properly, use this method after every question and save with the correct scheme
	// replaced method to here, needs a fix
	public void saveCurrentState (){
		/*
		Gson gson = new GsonBuilder().setPrettyPrinting().create();
		//Text of the Document
		String textToWrite = gson.toJson(answers);
		//Checking the availability state of the External Storage.
		String state = Environment.getExternalStorageState();
		if (!Environment.MEDIA_MOUNTED.equals(state)) {
			
			//If it isn't mounted - we can't write into it.
			return;
		}
		
		//Create a new file that points to the root directory, with the given name:
		File file = new File(getExternalFilesDir(null), this.getState().getQuestionnaire().getName() + ".json");
		
		//This point and below is responsible for the write operation
		try {
			file.createNewFile();
			BufferedWriter writer = new BufferedWriter(new FileWriter(file));
			writer.write(textToWrite);
			
			writer.close();
			Toast myToast = Toast.makeText(this, "Gespeichert!", Toast.LENGTH_SHORT);
			myToast.show();
		}
		catch (Exception e) {
			e.printStackTrace();
			Toast myToast = Toast.makeText(this, "Nicht Gespeichert!", Toast.LENGTH_SHORT);
			myToast.show();
		}
		
	    */
	}
}
