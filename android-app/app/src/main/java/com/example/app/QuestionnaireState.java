package com.example.app;

import android.app.Activity;
import android.os.Environment;
import android.support.annotation.Nullable;
import android.widget.Toast;

import com.example.app.answer.Answer;
import com.example.app.answer.Answers;
import com.example.app.question.Question;
import com.example.app.question.Questionnaire;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import org.jetbrains.annotations.Contract;
import org.jetbrains.annotations.NotNull;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.util.ArrayList;
import java.util.List;

public final class QuestionnaireState {
	private static final List<Answer> answersList = new ArrayList<>(32);
	@Nullable
	private static Questionnaire questionnaire;
	@Nullable
	private static List<Question> questionsList;
	@Nullable
	private static int[][] conditionMatrix;
	private static int currentQID = -1;

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

	static void giveAnswer(@Nullable final Answer answer) {
		if (answer == null) {
			//simple null answer, do not store, go straight to next question
			currentQID += 1;
			if (questionsList == null) {
				throw new AssertionError();
			}
			if (currentQID == questionsList.size()) {
				currentQID = -1;
			}
			return;
		}

		if ((currentQID != answer.getId())) {
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

	/**
	 * save the current list of answers to disk
	 * <p>
	 * PRE: questionnaire must not be null
	 *
	 * @param externalFilesDir must be this.getExternalFilesDir(), cannot be called from static context
	 *                         TODO: find a way to do that?
	 * @return boolean true, if write was successful
	 * false, else
	 */
	static boolean save(@NotNull final File externalFilesDir) {
		assert (questionnaire != null);

		Gson gson = new GsonBuilder().setPrettyPrinting().create();
		//Text of the Document
		String textToWrite = gson.toJson(new Answers(questionnaire, answersList));
		//Checking the availability state of the External Storage.
		String state = Environment.getExternalStorageState();
		if (!Environment.MEDIA_MOUNTED.equals(state)) {
			//If it isn't mounted - we can't write into it.
			return false;
		}

		//Create a new file that points to the root directory, with the given name:
		File file = new File(externalFilesDir, questionnaire.getName() + ".json");

		//This point and below is responsible for the write operation
		try {
			final boolean success = file.createNewFile();
			if (!success) {
				//file already exists
				final boolean hasDeleted = file.delete();
				if (!hasDeleted) {
					return false;
				}
				final boolean hasCreatedNew = file.createNewFile();
				if (!hasCreatedNew) {
					//i just don't know what went wrong
					return false;
				}
			}
			BufferedWriter writer = new BufferedWriter(new FileWriter(file));
			writer.write(textToWrite);

			writer.close();
			return true;
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
	}


	/**
	 * debug function to display currently stored answers
	 *
	 * @param source activity where display should happen (for Toast)
	 */
	static void display_DEBUG(Activity source) {
		for (Answer answer : answersList) {
			Toast.makeText(source, answer.toString(), Toast.LENGTH_LONG).show();
		}
	}

	private QuestionnaireState() {
	}
}
