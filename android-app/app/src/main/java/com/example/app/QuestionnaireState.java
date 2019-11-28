package com.example.app;

import android.app.Activity;
import android.support.annotation.Nullable;
import android.widget.Toast;

import com.example.app.answer.Answers;
import com.example.app.question.Question;
import com.example.app.question.Questionnaire;

import org.jetbrains.annotations.Contract;
import org.jetbrains.annotations.NotNull;

import java.util.ArrayList;
import java.util.List;

public final class QuestionnaireState {
	private static final List<Answer> answersList = new ArrayList<>(32);
	@Nullable
	private static Questionnaire questionnaire = null;
	@Nullable
	private static List<Question> questionsList = null;
	@Nullable
	private static int[][] conditionMatrix = null;
	private static int currentQID = -1;

	private QuestionnaireState() {
	}

	static void setQuestionnaire(@NotNull final Questionnaire givenQuestionnaire) {
		questionnaire = givenQuestionnaire;

		questionsList = questionnaire.getQuestionList();

		// TODO : who decided to start indexing in the questionnaires with 1? this leads to this stupid code
		// TODO : also, this throws a lot of things off
		// change this a lot to implement conditions
		// layout:
		// int nextQuestionID = conditionMatrix[currentQuestionID][chosenOptionID];
		// gets big for MultipleChoice/Table...
		// BETTER BE 0-INDEXED!!!
		if (questionsList == null) {
			throw new AssertionError();
		}
		final int qListSize = questionsList.size();
		conditionMatrix = new int[qListSize][];
		for (int i = 0; i < qListSize; i++) {
			final int amountPossibleOutcomes = questionsList.get(i).getAmountPossibleOutcomes();
			conditionMatrix[i] = new int[amountPossibleOutcomes];
			for (int j = 0; j < amountPossibleOutcomes; j++) {
				// put condition changes here
				conditionMatrix[i][j] = i == qListSize - 1 ? -1 : i + 1;
			}
		}

		// 1, because questions are currently 1-indexed
		currentQID = 1;
		answersList.clear();
	}

	@Contract(pure = true)
	public static Question getCurrentQuestion() {
		if (questionsList == null) {
			throw new AssertionError();
		}

		// -1, because still 1-indexed
		return questionsList.get(questionID_to_MatrixIndex(currentQID));
	}

	//this can be removed, if questions start getting indexed from 0
	@Contract(pure = true)
	private static int questionID_to_MatrixIndex(final int qIdx) {
		return qIdx - 1;
	}

	static void giveAnswer(@NotNull final Answer answer) {
		if (answer == null) {
			// android does not have the runtime checks for the annotation
			// this check should be removed once all Questions return a non-null answer
			currentQID += 1;
			if (questionsList == null) {
				throw new AssertionError();
			}
			if (currentQID == questionsList.size()) {
				currentQID = -1;
			}
			return;
		}

		if ((currentQID != answer.getQuestionID())) {
			throw new AssertionError();
		}

		//add answer to list
		answersList.add(answer);

		// TODO :
		// look for next question
		if (conditionMatrix == null) {
			throw new AssertionError();
		}
		//currentQID = conditionMatrix[questionID_to_MatrixIndex(currentQID)][answer.getChosenOutcomeIdx()];

		// only step to the next one for now
		currentQID += 1;
		if (questionsList == null) {
			throw new AssertionError();
		}
		if (currentQID == questionsList.size()) {
			currentQID = -1;
		}
	}

	@Contract(pure = true)
	static boolean nextIsQuestion() {
		// currentQ is only -1 if last answer lead to end of questionnaire
		return currentQID != -1;
	}
	
	public List<Answers> getAnswers() {
		return answers;
	}
	static void save() {
		// TODO : send questionnaire and answersList to saveAnswers-something
		questionnaire = null;
		for (int i = 0; i < answersList.size(); i++) {
			answersList.set(i, null);
		}
		answersList.clear();
	}

	static void display_DEBUG(Activity source) {
		for (Answer answer : answersList) {
			Toast.makeText(source, answer.toString(), Toast.LENGTH_LONG).show();
		}
	}
}
