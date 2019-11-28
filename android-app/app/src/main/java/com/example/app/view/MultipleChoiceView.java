package com.example.app.view;

import android.support.constraint.ConstraintLayout;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.Space;
import android.widget.TextView;

import com.example.app.QuestionDisplayActivity;
import com.example.app.R;
import com.example.app.answer.Answer;
import com.example.app.answer.MultipleChoiceAnswer;
import com.example.app.answer.SingleChoiceAnswer;
import com.example.app.question.ChoiceQuestion;
import com.example.app.question.Option;
import com.example.app.question.OptionType;

import org.jetbrains.annotations.NotNull;

import java.util.ArrayList;
import java.util.List;

// TODO: suppress virtual keyboard if displaying an edit text
// TODO: select button by clicking on option text or text box and not just the button

// TODO : break this up into SingleChoiceView and MultipleChoiceView

public class MultipleChoiceView extends QuestionDisplayView {
	
	// the corresponding question
	private final ChoiceQuestion question;
	// root node of the multiple choice view
	private ConstraintLayout rootView;
	// view containing the option views
	private LinearLayout optionContainer;
	// list of all button views
	private final List<OptionView> optionViews = new ArrayList<>();

	// constructor
	MultipleChoiceView(QuestionDisplayActivity activity, ChoiceQuestion question) {
		super(activity);
		this.question = question;
		init();
	}
	
	
	private void init() {
		rootView = (ConstraintLayout) View.inflate(getActivity(), R.layout.multiple_choice_view, null);
		optionContainer = rootView.findViewById(R.id.MultipleChoiceOptionContainer);
		
		// set questionTypeText
		TextView questionTypeTextView = rootView.findViewById(R.id.MultipleChoiceQuestionTypeText);
		questionTypeTextView.setText(question.type.name());
		
		// set questionText
		TextView questionTextView = rootView.findViewById(R.id.MultipleChoiceQuestionText);
		questionTextView.setText(question.questionText);
		
		// find dividingLine
		View dividingLine = rootView.findViewById(R.id.MultipleChoiceDividingLine);
		
		// create buttons
		createOptions();
	}
	
	// create option views
	private void createOptions() {
		for (int i = 0; i < question.options.size(); ++i) {
			// space between options
			Space space = new Space(getActivity());
			space.setLayoutParams(new ViewGroup.LayoutParams(0, 30));
			optionContainer.addView(space);
			
			Option option = question.options.get(i);
			final int finalI = i;
			OptionView view = OptionView.create(getActivity(), option, question, v -> buttonClicked(optionViews.get(finalI)));
			optionContainer.addView(view.getContainer());
			optionViews.add(view);
			
			// check if option is edit text and add listener
			if (view.getEditText() != null) {
				view.getEditText().addTextChangedListener(new TextWatcher() {
					@Override
					public void beforeTextChanged(final CharSequence s, final int start, final int count, final int after) {
					}
					
					@Override
					public void onTextChanged(final CharSequence s, final int start, final int before, final int count) {
					}
					
					@Override
					public void afterTextChanged(final Editable s) {
						updateNextButtonEnabled();
					}
				});
			}
			
		}
	}
	
	// enable or disable 'next' button depending on whether any button is checked
	// also disable other radio buttons if this is that kind of question
	private void buttonClicked(OptionView view) {
		if (question.isSingleChoice()) {
			for (OptionView otherView : optionViews)
				if (otherView != view)
					otherView.setChecked(false);
		}
		updateNextButtonEnabled();
	}
	
	// enable or disable 'next' button depending on whether any button is checked
	private void updateNextButtonEnabled() {
		boolean enabled = nextButtonAllowed();
		getActivity().setNextButtonEnabled(enabled);
	}
	
	// true if next button should be enabled
	private boolean nextButtonAllowed() {
		return areAllCheckedValid() && isAnyButtonChecked();
	}
	
	// true if any button is checked
	private boolean isAnyButtonChecked() {
		for (OptionView optionView : optionViews) {
			if (optionView.isChecked()) {
				return true;
			}
		}
		return false;
	}
	
	// true if all checked edit texts are not empty
	private boolean areAllCheckedValid() {
		for (OptionView optionView : optionViews) {
			if (optionView.isChecked()) {
				if (optionView.getOption().getType() == OptionType.EnterText) {
					assert optionView.getEditText() != null;
					if ("".equals(optionView.getEditText().getText().toString()))
						return false;
				}
			}
		}
		return true;
	}
	
	// implementation of abstract method from QuestionDisplayView
	@Override
	public View getView() {
		return rootView;
	}

	@NotNull
	@Override
	public Answer getCurrentAnswer() {
		if (question.isSingleChoice()) {
			return new SingleChoiceAnswer(question, getIdOfCheckedButton());
		} else {
			return new MultipleChoiceAnswer(question, getIdsOfAllChecked());
		}
	}

	/**
	 * get indexes of checked buttons
	 * for multiple choice only
	 *
	 * @return List<Integer> with indexes of checked button
	 */
	@NotNull
	private List<Integer> getIdsOfAllChecked() {
		final List<Integer> list = new ArrayList<>(question.options.size());
		for (OptionView optionView : optionViews) {
			if (optionView.isChecked()) {
				// -1 to account for 1-indexing of Option
				list.add(optionView.getOption().getId() - 1);
			}
		}
		return list;
	}

	/**
	 * get index of checked button
	 * for single choice only
	 *
	 * @return id of checked button
	 */
	private int getIdOfCheckedButton() {
		for (OptionView optionView : optionViews) {
			if (optionView.isChecked()) {
				// -1 to account for 1-indexing of Option
				return optionView.getOption().getId() - 1;
			}
		}
		//none are checked, this method should not have been called in this case!
		throw new IllegalStateException("answer was requested of single choice question, but none was clicked");
	}
}

