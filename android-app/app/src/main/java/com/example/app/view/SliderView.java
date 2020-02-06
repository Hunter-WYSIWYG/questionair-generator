package com.example.app.view;

import android.content.SharedPreferences;
import android.support.constraint.ConstraintLayout;
import android.view.View;
import android.widget.TextView;

import com.example.app.QuestionDisplayActivity;
import com.example.app.QuestionnaireState;
import com.example.app.R;
import com.example.app.answer.Answer;
import com.example.app.answer.AnswerCollection;
import com.example.app.question.SliderQuestion;
import com.warkiz.widget.IndicatorSeekBar;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;

import static com.example.app.MainActivity.username;

public class SliderView extends QuestionDisplayView {
	
	// the corresponding question
	private final SliderQuestion question;
	// container of slider
	private ConstraintLayout container;
	// slider
	private IndicatorSeekBar seekBar;
	//current State
	private QuestionnaireState questionnaireState;
	
	// constructor
	public SliderView (QuestionDisplayActivity activity, SliderQuestion question, QuestionnaireState state ) {
		super (activity);
		this.question = question;
		this.questionnaireState =state;
		this.init();
	}
	
	private void init () {
		this.container = (ConstraintLayout) View.inflate (this.getActivity (), R.layout.slider_view, null);
		
	
		
		// set questionText
		TextView questionTextView = this.container.findViewById (R.id.SliderQuestionText);
		questionTextView.setText (this.question.questionText);
		
		// set hint
		TextView hintTextView = this.container.findViewById (R.id.hint);
		hintTextView.setText (this.question.hint);
		
		// find dividingLine
		View dividingLine = this.container.findViewById (R.id.SliderDividingLine);
		
		// set leftText
		TextView leftText = this.container.findViewById (R.id.leftText);
		leftText.setText (this.question.leftText);
		
		// set rightText
		TextView rightText = this.container.findViewById (R.id.rightText);
		rightText.setText (this.question.rightText);
		
		// create slider
		this.createSlider ();
		
		// next button always enabled
		this.getActivity ().setNextButtonEnabled (true);
	}
	
	// create slider
	private void createSlider () {
		int min = this.question.polarMin;
		int max = this.question.polarMax;
		this.seekBar = this.container.findViewById (R.id.Slider);
		this.seekBar.setMin (min);
		this.seekBar.setMax (max);
		this.seekBar.setProgress (1);
		int ticks = 1 + (max - min);
		this.seekBar.setTickCount (ticks);
	}
	
	// getter
	@Override
	public View getView () {
		return container;
	}
	
	@Override
	public AnswerCollection getCurrentAnswer () {
		Calendar calendar = Calendar.getInstance (); // gets current instance of the calendar
		Answer answer = new Answer (this.question.type.toString(), this.seekBar.getProgress(), "");
		List<Answer> answerList = new ArrayList<Answer> ();
		answerList.add(answer);
		AnswerCollection answerCollection = new AnswerCollection (this.questionnaireState.getQuestionnaire ().getName (), getPreferenceValue (), calendar.getTime (), (int) (this.questionnaireState.getQuestionnaire ().getID ()), this.question.type, this.question.id, this.question.questionText, answerList);
		return answerCollection;
	}

	// get shared preference username
	public String getPreferenceValue ()	{
		SharedPreferences sp = this.getActivity ().getSharedPreferences (username, 0);
		String str = sp.getString ("key","");
		return str;
	}
}
