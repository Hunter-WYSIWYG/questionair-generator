package com.example.app.view;

import android.support.constraint.ConstraintLayout;
import android.view.View;
import android.widget.TextView;

import com.example.app.QuestionDisplayActivity;
import com.example.app.R;
import com.example.app.answer.Answer;
import com.example.app.question.PercentSliderQuestion;
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
		TextView questionNumber = this.container.findViewById (R.id.questionNumber);
		questionNumber.setText("Fragenummer: " + question.questionID);
		
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
	public List<Answer> getCurrentAnswer () {
		List<Answer> returnList = new ArrayList<>();
		returnList.add (new Answer (this.question.questionID, this.seekBar.getProgress ()));
		return returnList;
	}
}
