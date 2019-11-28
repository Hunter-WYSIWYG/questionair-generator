package com.example.app.answer;


import com.example.app.question.ChoiceQuestion;
import com.google.gson.annotations.SerializedName;

import org.jetbrains.annotations.NotNull;

import java.util.Collection;

public class MultipleChoiceAnswer extends Answer {
	@SerializedName("outcomeID")
	@NotNull
	private final Collection<Integer> checkedButtonIds;

	private final int amountButtons;

	// TODO : add editText entered text to constructor? / add field to class?
	public MultipleChoiceAnswer(@NotNull final ChoiceQuestion givenQuestion, @NotNull Collection<Integer> givenCheckedButtonsList) {
		super(givenQuestion);
		//always power of 2
		amountButtons = 31 - Integer.numberOfLeadingZeros(givenQuestion.getAmountPossibleOutcomes());
		checkedButtonIds = givenCheckedButtonsList;
	}

	@Override
	public int getChosenOutcomeIdx() {
		//create binary number, checked boxes are 1, rest 0, last box is at the least significant bit
		int chosenOutcome = 0;
		for (int i = 0; i < amountButtons; i++) {
			chosenOutcome <<= 1;
			// TODO : maybe use faster method instead of contains() ?
			if (checkedButtonIds.contains(i)) {
				chosenOutcome |= 1;
			}
		}
		return chosenOutcome;
	}
}
