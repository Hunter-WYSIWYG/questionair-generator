package com.example.app.view;

import android.support.constraint.ConstraintLayout;
import android.view.View;
import android.widget.TextView;

import com.example.app.QuestionDisplayActivity;
import com.example.app.R;
import com.example.app.answer.Answer;
import com.example.app.answer.AnswerCollection;
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
	//current State
	private QuestionnaireState questionnaireState;
	
	// constructor
	public PercentSliderView (QuestionDisplayActivity activity, PercentSliderQuestion question, QuestionnaireState state) {
		super (activity);
		this.question = question;
		this.questionnaireState = state;
		this.init ();
	}
	
	private void init () {
		this.container = (ConstraintLayout) View.inflate (this.getActivity (), R.layout.percent_slider_view, null);
		
		// set questionTypeText
		TextView questionTypeTextView = this.container.findViewById (R.id.SliderQuestionTypeText);
		questionTypeTextView.setText (this.question.type.name ());
		
		// set question Number
		TextView questionNumber = this.container.findViewById (R.id.questionNumber);
		questionNumber.setText ("Fragenummer: " + this.question.id);
		
		// set questionText
		TextView questionTextView = this.container.findViewById (R.id.SliderQuestionText);
		questionTextView.setText (this.question.questionText);
		
		// set hint
		TextView hintTextView = this.container.findViewById (R.id.hint);
		hintTextView.setText (this.question.hint);
		
		// find dividingLine
		View dividingLine = this.container.findViewById (R.id.SliderDividingLine);
		
		// create slider
		createSlider();
		
		// set leftText
		TextView leftText = this.container.findViewById (R.id.leftText);
		leftText.setText (this.question.leftText);
		
		// set rightText
		TextView rightText = this.container.findViewById (R.id.rightText);
		rightText.setText (this.question.rightText);
		
		// next button always enabled
		this.getActivity ().setNextButtonEnabled (true);
	}
	
	// create slider
	private void createSlider () {
		this.seekBar = container.findViewById (R.id.Slider);
		this.seekBar.setMin (0);
		this.seekBar.setMax (100);
		this.seekBar.setIndicatorTextFormat ("${PROGRESS} %");
	}
	
	// getter
	@Override
	public View getView () {
		return this.container;
	}
	
	@Override
	public AnswerCollection getCurrentAnswer () {
		Calendar calendar = Calendar.getInstance (); // gets current instance of the calendar
		Answer answer = new Answer (this.question.type.toString (), this.seekBar.getProgress () , "");
		List<Answer> answerList=new ArrayList<Answer> ();
		answerList.add (answer);
		AnswerCollection answerCollection = new AnswerCollection (this.questionnaireState.getQuestionnaire ().getName (), calendar.getTime (), (int) (this.questionnaireState.getQuestionnaire ().getID ()), this.question.type, this.question.id, this.question.questionText, answerList);
		return answerCollection;
	}

	@Override
	public Question getQuestion() {
		return question;
	}
}
