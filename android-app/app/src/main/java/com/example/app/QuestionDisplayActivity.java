package com.example.app;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.os.Environment;
import android.support.annotation.NonNull;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.Toast;

import com.example.app.answer.AnswerCollection;
import com.example.app.view.QuestionDisplayView;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.Serializable;
import java.util.List;

public class QuestionDisplayActivity extends AppCompatActivity {
	
	private QuestionDisplayView questionView;
	private Button              nextButton;
	
	private QuestionnaireState state;
	
	// is called when this activity is started
	@Override protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_question_display);
		
		state = (QuestionnaireState) getIntent().getSerializableExtra("state");
		nextButton = findViewById(R.id.QuestionDisplayNextButton);
		// xml is divided into the questionViewContainer, the questionView inside the container and the "next" button
		final LinearLayout contentContainer = findViewById(R.id.QuestionDisplayContentContainer);
		
		questionView = QuestionDisplayView.create(this);
		
		// insert as the new first element, before the space filler and the next button
		contentContainer.addView(questionView.getView(), 0);
		
		nextButton.setOnClickListener(v -> nextButtonClicked());
	}
	
	// next button is clicked, update questionnaire state and go to next question
	private void nextButtonClicked() {
		AnswerCollection answerCollection = questionView.getCurrentAnswer();
		state.currentQuestionAnswered(answerCollection);
		if (!state.isFinished()) {
			displayCurrentQuestion(state, this);
		} else {
			save(state.getAnswerCollectionList());
			Intent intent = new Intent(this, QuestionnaireFinishedActivity.class);
			startActivity(intent);
			finish();
		}
	}
	
	// displays the current question of the questionnaire state
	public static void displayCurrentQuestion(Serializable questionnaireState,
	                                          @NonNull Activity activity) {
		Intent intent = new Intent(activity, QuestionDisplayActivity.class);
		intent.putExtra("state", questionnaireState);
		activity.startActivity(
				intent); // starting our own activity (onCreate) with questionnaire state so we can save it
		activity.finish(); // prevent the back button
	}
	
	// save after clicking next button
	public void save(List<AnswerCollection> answers) {
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
		File file = new File(MainActivity.ANSWERS_DIR,
		                     getState().getQuestionnaire().getName() + ".json");
		
		//This point and below is responsible for the write operation
		try {
			if (!file.createNewFile()) {
				if (file.delete()) {
					if (!file.createNewFile()) {
						throw new Exception("text");
					}
				} else {
					throw new Exception("text");
				}
			}
			BufferedWriter writer = new BufferedWriter(new FileWriter(file));
			writer.write(textToWrite);
			writer.close();
		} catch (Exception e) {
			e.printStackTrace();
			Toast myToast =
					Toast.makeText(this, "Error. Antworten nicht Gespeichert!", Toast.LENGTH_SHORT);
			myToast.show();
		}
	}
	
	// getter
	public QuestionnaireState getState() {
		return state;
	}
	
	// TODO what does it do? comment your functions boys!
	public void onDestroy() {
		super.onDestroy();
		save(state.getAnswerCollectionList());
		finish();
	}
	
	// set next button to enabled or disabled
	public void setNextButtonEnabled(boolean enabled) {
		nextButton.setEnabled(enabled);
	}
	
	// create popup if back button is pressed
	public void onBackPressed() {
		AlertDialog.Builder alertDialog = new AlertDialog.Builder(this);
		alertDialog.setTitle("");
		alertDialog.setMessage("Wollen Sie den Fragebogen verlassen?");
		alertDialog.setCancelable(true);
		
		alertDialog.setPositiveButton("Ja", (dialog, id) -> {
			dialog.cancel();
			Intent intent = new Intent(this, MainActivity.class);
			startActivity(intent);
			finish();
		});
		
		alertDialog.setNegativeButton("Abbrechen", (dialog, id) -> dialog.cancel());
		
		AlertDialog alert = alertDialog.create();
		alert.show();
	}
}

