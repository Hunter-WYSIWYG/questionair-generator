package com.example.app;

import com.example.app.question.Question;
import com.example.app.question.Questionnaire;

import org.jetbrains.annotations.NotNull;

import java.util.List;

final class QuestionnaireState {
	private Questionnaire questionnaire = null;
	private int[][] conditionMatrix = null;

	private QuestionnaireState() {
	}

	void setQuestionnaire(final @NotNull Questionnaire givenQuestionnaire) {
		questionnaire = givenQuestionnaire;

		final List<Question> qList = questionnaire.getQuestionList();
		conditionMatrix = new int[qList.size()][];
		for (int i = 0; i < qList.size(); i++) {
			Question q = qList.get(i);
			switch (q.type) {
				case SingleChoice:

					break;
				case MultipleChoice:
					break;
				case Slider:
					break;
				case PercentSlider:
					break;
				case Note:
					break;
				case Table:
					break;
				case SliderButton:
					break;
			}
			conditionMatrix[i] = new int[0];
		}
	}
}
