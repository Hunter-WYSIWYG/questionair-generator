package com.example.app;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.os.Environment;
import android.support.v7.app.AppCompatActivity;
import android.view.View;
import android.widget.Button;
import android.widget.LinearLayout;

import android.widget.Toast;
import com.example.app.answer.Answers;
import com.example.app.view.QuestionDisplayView;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.util.List;

public class QuestionDisplayActivity extends AppCompatActivity {

	// xml is divided into the questionViewContainer, the questionView inside the container and the "next" button
	private LinearLayout contentContainer;
	private QuestionDisplayView questionView;
	private Button nextButton;

	private QuestionnaireState state;

	// getter
	public QuestionnaireState getState () {
		return state;
	}

	// displays the current question of the questionnaire state
	public static void displayCurrentQuestion (QuestionnaireState questionnaireState, Activity activity) {
		Intent intent = new Intent (activity, QuestionDisplayActivity.class);
		intent.putExtra ("state", questionnaireState);
		activity.startActivity (intent); // starting our own activity (onCreate) with questionnaire state so we can save it
		activity.finish (); // prevent the back button
		// TODO: if back button pressed -> popup with "sind sie sicher dass sie den fragebogen abbrechen wollen?"
	}

	// is called when this activity is started
	@Override
	protected void onCreate (Bundle savedInstanceState) {
		super.onCreate (savedInstanceState);
		setContentView(R.layout.activity_question_display);
		
		state = (QuestionnaireState) getIntent().getSerializableExtra("state");
		nextButton = findViewById(R.id.QuestionDisplayNextButton);
		contentContainer = findViewById(R.id.QuestionDisplayContentContainer);
		
		questionView = QuestionDisplayView.create(this);

		// insert as the new first element, before the space filler and the next button
		contentContainer.addView(questionView.getView(), 0);
		
		nextButton.setOnClickListener(v -> nextButtonClicked());
	}

	// next button is clicked, update questionnaire state and go to next question
	private void nextButtonClicked () {
		Answers answers = questionView.getCurrentAnswer();
		state.currentQuestionAnswered(answers);
		if (!state.isFinished()) {
			displayCurrentQuestion(state, this);
		}
		else {
			save(state.getAnswers());
			Intent intent = new Intent (this, QuestionnaireFinishedActivity.class);
			startActivity(intent);
			finish();
		}
	}
	
	public void onDestroy() {
		
		super.onDestroy();
		save(state.getAnswers());
		finish();
		
	}
	
	// set next button to enabled or disabled
	public void setNextButtonEnabled(boolean enabled) {
		nextButton.setEnabled(enabled);
		
		// TODO: color 'next' button depending on enabled or not
	}
	public void save(List<Answers> answers) {
		Gson gson = new GsonBuilder().setPrettyPrinting().create();
		//Text of the Document
		String textToWrite = gson.toJson(answers);
		//Checking the availability state of the External Storage.
		String state = Environment.getExternalStorageState();
		if (!Environment.MEDIA_MOUNTED.equals(state)) {
				
				//If it isn't mounted - we can't write into it.
				return;
			}
			
		//Create a new file that points to the root directory, with the given name:
		File file = new File(getExternalFilesDir(null), this.getState().getQuestionnaire().getName() + ".json");
			
		//This point and below is responsible for the write operation
		try {
				file.createNewFile();
				BufferedWriter writer = new BufferedWriter(new FileWriter(file));
				writer.write(textToWrite);
				
				writer.close();
				Toast myToast = Toast.makeText(this, "Gespeichert!", Toast.LENGTH_SHORT);
				myToast.show();
		}
		catch (Exception e) {
				e.printStackTrace();
				Toast myToast = Toast.makeText(this, "Nicht Gespeichert!", Toast.LENGTH_SHORT);
				myToast.show();
		}
	}
	
}

