package com.example.app.view;

import android.support.constraint.ConstraintLayout;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.SeekBar;
import android.widget.TextView;
import com.example.app.QuestionDisplayActivity;
import com.example.app.R;
import com.example.app.answer.Answer;
import com.example.app.question.ChoiceQuestion;
import com.example.app.question.SliderQuestion;
import com.warkiz.widget.IndicatorSeekBar;

import java.util.ArrayList;
import java.util.List;

public class SliderView extends QuestionDisplayView {
	
	// the corresponding question
	private final SliderQuestion question;
	// container of slider
	private ConstraintLayout container;
	// slider
	private IndicatorSeekBar seekBar;

	// constructor
	public SliderView (QuestionDisplayActivity activity, SliderQuestion question) {
		super (activity);
		this.question = question;
		
		this.init ();
	}
	
	private void init () {
		this.container = (ConstraintLayout) View.inflate (this.getActivity (), R.layout.slider_view, null);
		
		// set questionTypeText
		TextView questionTypeTextView = this.container.findViewById (R.id.SliderQuestionTypeText);
		questionTypeTextView.setText (this.question.type.name ());
		
		// set questionText
		TextView questionTextView = this.container.findViewById (R.id.SliderQuestionText);
		questionTextView.setText (this.question.questionText);
		
		// find dividingLine
		View dividingLine = this.container.findViewById (R.id.SliderDividingLine);
		
		// create slider
		this.createSlider ();
		
		// next button always enabled
		this.getActivity ().setNextButtonEnabled (true);
	}
	
	// create slider
	private void createSlider () {
		this.seekBar = this.container.findViewById (R.id.Slider);
		this.seekBar.setMin ((float) question.minValue);
		this.seekBar.setMax ((float) question.maxValue);
		this.seekBar.setProgress ((float) question.stepSize);
		int ticks = 1 + (int) Math.round ((question.maxValue - question.minValue) / question.stepSize);
		this.seekBar.setTickCount (ticks);
	}
	
	@Override
	public View getView () {
		return this.container;
	}
	
	@Override
	public List<Answer> getCurrentAnswer () {
		return null;
	}
}
