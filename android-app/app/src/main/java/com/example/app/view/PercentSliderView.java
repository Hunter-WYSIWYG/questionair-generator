package com.example.app.view;

import android.support.constraint.ConstraintLayout;
import android.view.View;
import android.widget.TextView;

import com.example.app.QuestionDisplayActivity;
import com.example.app.R;
import com.example.app.answer.Answer;
import com.example.app.answer.Condition;
import com.example.app.question.PercentSliderQuestion;
import com.example.app.question.Question;
import com.warkiz.widget.IndicatorSeekBar;

import java.util.ArrayList;
import java.util.List;

public class PercentSliderView extends QuestionDisplayView  {
	
	// the corresponding question
	private final PercentSliderQuestion question;
	// container of slider
	private ConstraintLayout container;
	// slider
	private IndicatorSeekBar seekBar;
	
	// constructor
	public PercentSliderView (QuestionDisplayActivity activity, PercentSliderQuestion question) {
		super (activity);
		this.question = question;
		
		init();
	}
	
	private void init () {
		container = (ConstraintLayout) View.inflate(getActivity(), R.layout.percent_slider_view, null);
		
		// set questionTypeText
		TextView questionTypeTextView = container.findViewById(R.id.SliderQuestionTypeText);
		questionTypeTextView.setText(question.type.name());
		
		// set question Number
		TextView questionNumber = container.findViewById(R.id.questionNumber);
		questionNumber.setText("Fragenummer: " + question.questionID);
		
		// set questionText
		TextView questionTextView = container.findViewById(R.id.SliderQuestionText);
		questionTextView.setText(question.questionText);
		
		// set hint
		TextView hintTextView = this.container.findViewById(R.id.hint);
		hintTextView.setText(this.question.hint);
		
		// find dividingLine
		View dividingLine = container.findViewById(R.id.SliderDividingLine);
		
		// create slider
		createSlider();
		
		// set leftText
		TextView leftText = container.findViewById(R.id.leftText);
		leftText.setText(question.leftText);
		
		// set rightText
		TextView rightText = container.findViewById(R.id.rightText);
		rightText.setText(question.rightText);
		
		
		// next button always enabled
		getActivity().setNextButtonEnabled(true);
	}
	
	// create slider
	private void createSlider () {
		seekBar = container.findViewById(R.id.Slider);
		seekBar.setMin(0);
		seekBar.setMax(100);
		seekBar.setIndicatorTextFormat("${PROGRESS} %");
	}
	
	@Override
	public View getView () {
		return container;
	}
	
	@Override
	public List<Condition> getCurrentCondition() {
		List<Condition> returnList = new ArrayList<>();
		returnList.add(new Condition(question.questionID, seekBar.getProgress()));
		return returnList;
	}
	
	@Override
	public List<Answer> getCurrentAnswer() {
		return new ArrayList<>();
	}
	
	@Override
	public Question getQuestion() {
		return question;
	}
}
