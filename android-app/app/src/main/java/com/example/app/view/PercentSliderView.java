package com.example.app.view;

import android.support.annotation.Nullable;
import android.support.constraint.ConstraintLayout;
import android.view.View;
import android.widget.TextView;

import com.example.app.QuestionDisplayActivity;
import com.example.app.QuestionnaireState;
import com.example.app.R;
import com.example.app.answer.Answer;
import com.example.app.answer.Answers;
import com.example.app.question.PercentSliderQuestion;
import com.warkiz.widget.IndicatorSeekBar;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;

public class PercentSliderView extends QuestionDisplayView {
	
	// the corresponding question
	private final PercentSliderQuestion question;
	// container of slider
	private ConstraintLayout container;
	// slider
	private IndicatorSeekBar seekBar;
	//current State
	private QuestionnaireState qState;
	
	// constructor
	PercentSliderView(QuestionDisplayActivity activity, PercentSliderQuestion question, QuestionnaireState state) {
		super(activity);
		this.question = question;
		qState=state;
		init();
	}
	
	private void init() {
		container = (ConstraintLayout) View.inflate(getActivity(), R.layout.percent_slider_view, null);
		
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
		seekBar.setMin(0);
		seekBar.setMax(100);
		seekBar.setIndicatorTextFormat("${PROGRESS} %");
	}
	
	@Override
	public View getView() {
		return container;
	}

	@Nullable
	@Override
	public Answers getCurrentAnswer() {
		Calendar calendar = Calendar.getInstance(); // gets current instance of the calendar
		Answer ans=new Answer(question.type.toString(), seekBar.getProgress() , "");
		List<Answer> answerList=new ArrayList<Answer>();
		answerList.add(ans);
		Answers answers=new Answers(qState.getQuestionnaire().getName(),calendar.getTime(),(int) (qState.getQuestionnaire().getID()),question.type,question.id,question.questionText,answerList);
		return answers;
		
	}
}
