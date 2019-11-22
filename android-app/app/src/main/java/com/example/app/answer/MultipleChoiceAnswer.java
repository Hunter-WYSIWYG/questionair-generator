package com.example.app.answer;


import com.example.app.question.ChoiceQuestion;
import com.google.gson.annotations.SerializedName;

import org.jetbrains.annotations.NotNull;

import java.util.Collection;

/**
 * this is a sample subclass of answer for multiple choice questions
 * allows for better returning to QuestionnaireState to be properly handled
 */

public class MultipleChoiceAnswer extends Answer {
	@SerializedName("outcomeID")
	@NotNull
	private final int chosenOutcomeID;

	// TODO : add editText entered text to constructor? / add field to class?
	public MultipleChoiceAnswer(@NotNull final ChoiceQuestion givenQuestion, @NotNull Collection<Integer> givenCheckedButtonsList) {
		super(givenQuestion);

		//possible outcomes on multiple choice: 2^(amount buttons)
		//get amount buttons back
		final int amountButtons = 32 - Integer.numberOfLeadingZeros(givenQuestion.getAmountPossibleOutcomes());

		//create binary number, checked boxes are 1, rest 0, last box is at the least significant bit
		int chosenOutcome = 0;
		for (int i = 0; i < amountButtons; i++) {
			chosenOutcome <<= 1;
			// TODO : maybe use faster method instead of contains()?
			if (givenCheckedButtonsList.contains(i)) {
				chosenOutcome |= 1;
			}
		}
		chosenOutcomeID = chosenOutcome;
	}

	@Override
	public int getChosenOutcomeIdx() {
		return chosenOutcomeID;
	}
}
