package com.example.app;

import com.example.app.answer.Answer;
import com.example.app.question.ChoiceQuestion;
import com.example.app.question.Option;
import com.example.app.question.Question;
import com.example.app.question.Questionnaire;
import com.example.app.question.SliderButtonQuestion;
import com.example.app.question.TableQuestion;

import org.jetbrains.annotations.Contract;
import org.jetbrains.annotations.NotNull;

import java.util.ArrayList;
import java.util.List;

final public class QuestionnaireState {
	static private final List<Answer> answersList = new ArrayList<>(32);
	static private Questionnaire questionnaire = null;
	static private List<Question> questionsList = null;
	static private int[][] conditionMatrix = null;
	static private int currentQ = -1;
	
	private QuestionnaireState() {
	}
	
	static void setQuestionnaire(final @NotNull Questionnaire givenQuestionnaire) {
		questionnaire = givenQuestionnaire;
		
		questionsList = questionnaire.getQuestionList();
		
		// TODO: who decided to start indexing in the questionnaires with 0? this leads to this stupid code where the array is one size bigger and the first entry is always unused
		final int qListSize = questionsList.size();
		conditionMatrix = new int[qListSize + 1][];
		for (int i = 1; i <= qListSize; i++) {
			Question q = questionsList.get(i - 1);
			// breaking this up differently would probably be good
			// putting a matrix for this into the questionnaire JSON would be best,
			// or reading it straight from Question class
			switch (q.type) {
				case SingleChoice:
				case MultipleChoice:
					final ChoiceQuestion qCastChoice = (ChoiceQuestion) q;
					final List<Option> qOptionsChoice = qCastChoice.options;
					final int qIdxChoice = qCastChoice.id;
					if ((qIdxChoice != i))
						throw new AssertionError("qIdx was: " + qIdxChoice + ", i was: " + i);
					final int amountOptionsChoice = qOptionsChoice.size();
					conditionMatrix[i] = new int[amountOptionsChoice + 1];
					for (int j = 1; j <= amountOptionsChoice; j++) {
						// TODO: CONDITIONS -> which optionID leads to which new questionID
						conditionMatrix[i][j] = i != qListSize ? i + 1 : -1;
					}
					break;
				case Slider:
				case PercentSlider:
				case Note:
					// TODO : Slider position leads to different next question?
					conditionMatrix[i] = new int[] {i != qListSize ? i + 1 : -1};
					break;
				case Table:
					final TableQuestion qCastTable = (TableQuestion) q;
					final int qSizeTable = (int) qCastTable.size;
					final int qIdxTable = qCastTable.id;
					if ((qIdxTable != i))
						throw new AssertionError("qIdx was: " + qIdxTable + ", i was: " + i);
					final int amountOptionsTable = (qSizeTable) * (qSizeTable);
					conditionMatrix[i] = new int[amountOptionsTable];
					// these buttons are hopefully 0-indexed. i hope
					for (int j = 0; j < amountOptionsTable; j++) {
						// TODO: CONDITIONS -> which optionID leads to which new questionID
						conditionMatrix[i][j] = i != qListSize ? i + 1 : -1;
					}
					break;
				case SliderButton:
					final SliderButtonQuestion qCastSliderButton = (SliderButtonQuestion) q;
					final int qSizeSliderButton = (int) qCastSliderButton.size;
					final int qIdxSliderButton = qCastSliderButton.id;
					if ((qIdxSliderButton != i))
						throw new AssertionError("qIdx was: " + qIdxSliderButton + ", i was: " + i);
					final int amountOptionsSliderButton = (qSizeSliderButton) * (qSizeSliderButton);
					conditionMatrix[i] = new int[amountOptionsSliderButton];
					// these buttons are hopefully 0-indexed. i hope
					for (int j = 0; j < amountOptionsSliderButton; j++) {
						// TODO: CONDITIONS -> which optionID leads to which new questionID
						// TODO : Slider affects too? -> would need more entries!!!
						conditionMatrix[i][j] = i != qListSize ? i + 1 : -1;
					}
					break;
			}
			if ((conditionMatrix[i] == null))
				throw new AssertionError("Should have set condition matrix entries, but array still null");
		}
		
		currentQ = 0;
		answersList.clear();
	}
	
	@Contract (pure = true)
	public static Question getCurrentQuestion() {
		return questionsList.get(currentQ);
	}
	
	public static void giveAnswer(final @NotNull Answer answer) {
		final int currentQID = questionsList.get(currentQ).id;
		if ((answer.getQuestionID() != currentQID))
			throw new AssertionError("Answer was not for current question");
		
		//add answer to list
		answersList.add(answer);
		
		// look for next question
		currentQ = conditionMatrix[currentQID][answer.getOptionID()];
	}
	
	@Contract (pure = true)
	public static boolean nextIsQuestion() {
		// currentQ is only -1 if last answer leads to end of questionnaire
		return currentQ != -1;
	}
	
	public static void save() {
		// TODO : send questionnaire and answersList to saveAnswers-something
		questionnaire = null;
		for (int i = 0; i < answersList.size(); i++) {
			answersList.set(i, null);
		}
		answersList.clear();
	}
}
