package com.example.app;

import android.app.Activity;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.os.Environment;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.widget.Button;
import android.widget.LinearLayout;

import android.widget.Toast;

import com.example.app.answer.Answer;
import com.example.app.answer.AnswerCollection;
import com.example.app.question.Question;
import com.example.app.view.QuestionDisplayView;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class QuestionDisplayActivity extends AppCompatActivity {
	
	// xml is divided into the questionViewContainer, the questionView inside the container and the "next" button
	private LinearLayout contentContainer;
	private QuestionDisplayView questionView;
	private Button nextButton;
	
	private QuestionnaireState state;
	
	// current question for end time calculation
	private Question q;
	
	
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
	}
	
	// is called when this activity is started
	@Override
	protected void onCreate (Bundle savedInstanceState) {
		super.onCreate (savedInstanceState);
		setContentView (R.layout.activity_question_display);
		
		state = (QuestionnaireState) getIntent ().getSerializableExtra ("state");
		nextButton = findViewById (R.id.QuestionDisplayNextButton);
		contentContainer = findViewById (R.id.QuestionDisplayContentContainer);
		
		questionView = QuestionDisplayView.create (this);
		
		// insert as the new first element, before the space filler and the next button
		contentContainer.addView (questionView.getView (), 0);
		
		nextButton.setOnClickListener (v -> nextButtonClicked ());
		
		// get question now so the time limit can be checked later
		q = state.getCurrentQuestion();
	}
	
	// next button is clicked, update questionnaire state and go to next question
	private void nextButtonClicked () {
		
		// for testing show question time
		// Toast test = Toast.makeText(this, "" + (state.getCurrentQuestionEndTime()-System.currentTimeMillis()), Toast.LENGTH_LONG);
		// test.show();
		
		
		// if question has edit time
		if (q.questionTime != null) {
			// if time is up
			if (System.currentTimeMillis() > state.getCurrentQuestionEndTime()) {
				// create invalid answer and add it to the answer list
				AnswerCollection answerCollection = questionView.getCurrentAnswer ();
				List<Answer> dummyList = new ArrayList<>();
				dummyList.add(new Answer());
				AnswerCollection dummy = new AnswerCollection(
																answerCollection.getTitle(),
																answerCollection.getQuestionnaireAnswerTime(),
																answerCollection.getQuestionnaireId(),
																answerCollection.getQuestionType(),
																answerCollection.getQuestionId(),
																answerCollection.getText(),
																dummyList
											);
				state.currentQuestionAnswered(dummy);
			} else {
				// else, add the actual answer
				AnswerCollection answerCollection = questionView.getCurrentAnswer ();
				state.currentQuestionAnswered (answerCollection);
			}
		} else {
			// else, add the actual answer
			AnswerCollection answerCollection = questionView.getCurrentAnswer ();
			state.currentQuestionAnswered (answerCollection);
		}
		
		// if questionnaire has time limit
		if (state.getEndTime() != null) {
			final Date currentDate = new Date();
			if (currentDate.after(state.getEndTime())) {
				// if time is up, mark as finished
				save(state.getAnswerCollectionList ());
				Intent intent = new Intent (this, QuestionnaireFinishedActivity.class);
				startActivity (intent);
				finish ();
				return;
			}
		}
		
		
		if (!state.isFinished ()) {
			displayCurrentQuestion (state, this);
		}
		else {
			save(state.getAnswerCollectionList ());
			Intent intent = new Intent (this, QuestionnaireFinishedActivity.class);
			startActivity (intent);
			finish ();
		}
		
		
	}
	
	// TODO what does it do? comment your functions boys!
	public void onDestroy () {
		super.onDestroy ();
		save (state.getAnswerCollectionList ());
		finish ();
	}
	
	// set next button to enabled or disabled
	public void setNextButtonEnabled (boolean enabled) {
		nextButton.setEnabled (enabled);
	}
	
	// save after clicking next button
	public void save (List<AnswerCollection> answers) {
		Gson gson = new GsonBuilder ().setPrettyPrinting ().create ();
		//Text of the Document
		String textToWrite = gson.toJson (answers);
		//Checking the availability state of the External Storage.
		String state = Environment.getExternalStorageState ();
		if (!Environment.MEDIA_MOUNTED.equals (state)) {
			//If it isn't mounted - we can't write into it.
			return;
		}
		
		//Create a new file that points to the root directory, with the given name:
		File file = new File (getExternalFilesDir(null), this.getState ().getQuestionnaire ().getName () + ".json");
		
		//This point and below is responsible for the write operation
		try {
			file.createNewFile ();
			BufferedWriter writer = new BufferedWriter (new FileWriter(file));
			writer.write (textToWrite);
			writer.close ();
		}
		catch (Exception e) {
			e.printStackTrace ();
			Toast myToast = Toast.makeText (this, "Error. Antworten nicht Gespeichert!", Toast.LENGTH_SHORT);
			myToast.show ();
		}
	}
	
	// create popup if back button is pressed
	public void onBackPressed () {
		AlertDialog.Builder alertDialog = new AlertDialog.Builder (this);
		alertDialog.setTitle ("");
		alertDialog.setMessage ("Wollen Sie den Fragebogen verlassen?");
		alertDialog.setCancelable (true);
		
		alertDialog.setPositiveButton (
			"Ja",
			new DialogInterface.OnClickListener () {
				public void onClick (DialogInterface dialog, int id) {
					dialog.cancel ();
					Intent intent = new Intent (QuestionDisplayActivity.this, MainActivity.class);
					startActivity (intent);
					finish ();
				}
			});
		
		alertDialog.setNegativeButton (
			"Abbrechen",
			new DialogInterface.OnClickListener () {
				public void onClick (DialogInterface dialog, int id) {
					dialog.cancel ();
				}
			});
		
		AlertDialog alert = alertDialog.create ();
		alert.show ();
	}
}

