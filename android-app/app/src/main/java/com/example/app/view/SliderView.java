package com.example.app.view;

import android.support.annotation.Nullable;
import android.support.constraint.ConstraintLayout;
import android.view.View;
import android.widget.TextView;

import com.example.app.QuestionDisplayActivity;
import com.example.app.R;
import com.example.app.answer.SliderAnswer;
import com.example.app.question.SliderQuestion;
import com.warkiz.widget.IndicatorSeekBar;

public class SliderView extends QuestionDisplayView {

	// the corresponding question
	private final SliderQuestion question;
	// container of slider
	private ConstraintLayout container;
	// slider
	private IndicatorSeekBar seekBar;

	// constructor
	SliderView(QuestionDisplayActivity activity, SliderQuestion question) {
		super(activity);
		this.question = question;
		init();
	}

	private void init() {
		container = (ConstraintLayout) View.inflate(getActivity(), R.layout.slider_view, null);

		// set questionTypeText
		TextView questionTypeTextView = container.findViewById(R.id.SliderQuestionTypeText);
		questionTypeTextView.setText(question.type.name());

		// set questionText
		TextView questionTextView = container.findViewById(R.id.SliderQuestionText);
		questionTextView.setText(question.questionText);

		// find dividingLine
		View dividingLine = container.findViewById(R.id.SliderDividingLine);

		// create slider
		createSlider();

		// next button always enabled
		getActivity().setNextButtonEnabled(true);
	}

	// create slider
	private void createSlider() {
		seekBar = container.findViewById(R.id.Slider);
		seekBar.setMin((float) question.minValue);
		seekBar.setMax((float) question.maxValue);
		seekBar.setProgress((float) question.stepSize);
		int ticks = 1 + (int) Math.round((question.maxValue - question.minValue) / question.stepSize);
		seekBar.setTickCount(ticks);
	}

	@Override
	public View getView() {
		return container;
	}

	@Nullable
	@Override
	public SliderAnswer getCurrentAnswer() {
		return new SliderAnswer(question, seekBar.getProgress());
	}
}
