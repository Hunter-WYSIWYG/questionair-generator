package com.example.app;

import android.app.ActionBar;
import android.app.ListActivity;
import android.content.Intent;
import android.content.res.AssetManager;
import android.os.Bundle;
import android.support.constraint.ConstraintLayout;
import android.support.v7.app.AppCompatActivity;
import android.view.Menu;
import android.view.View;
import android.widget.*;

import com.example.app.question.Question;
import com.example.app.question.Questionnaire;
import com.google.gson.Gson;

import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class MainActivity extends ListActivity {
	// chosen questionnaire that the user will answer
	private Questionnaire currentQuestionnaire = null;
	// list of all questionnaires
	private List<Questionnaire> questionnaireList = new ArrayList<> ();

	@Override
	protected void onCreate (Bundle savedInstanceState) {
		super.onCreate (savedInstanceState);
		setContentView (R.layout.activity_main);
		
		// import all questionnaires - just for testing
		for (int i = 0; i < 20; i++) {
			this.questionnaireList.add (this.importQuestions ());
		}
		
		// set current questionnaire - just for testing
		this.currentQuestionnaire = this.questionnaireList.get (0);
		
		this.init ();
	}
	
	public boolean onCreateOptionsMenu (Menu menu) {
		ActionBar actionBar = getActionBar ();
		// TODO with navigation view
		return true;
	}
	
	// init layout
	private void init () {
		
		// create list of all questionnaires
		this.initList ();
		
	}
	// init list
	public void initList () {
		// list of string needed for arrayAdapter
		List<String> data = new ArrayList<> ();
		for (Questionnaire questionnaire : questionnaireList) {
			data.add (questionnaire.getName ());
		}
		
		// Create the ArrayAdapter use the item row layout and the list data.
		ArrayAdapter<String> arrayAdapter = new ArrayAdapter<>(this, R.layout.activity_main_list_row_element, R.id.listRowTextView, data);
		
		// Set this adapter to inner ListView object.
		this.setListAdapter(arrayAdapter);
		
	}
	// When user click list item, this method will be invoked.
	@Override
	protected void onListItemClick(ListView listView, View v, int position, long id) {
		// Get the list data adapter.
		ListAdapter listAdapter = listView.getAdapter();
		// Get user selected item object.
		Object selectItemObj = listAdapter.getItem(position);
		String itemText = (String)selectItemObj;
		
		
		
		// for testing only
		Toast test = Toast.makeText (this, "du hast ein list element angeclickt", Toast.LENGTH_LONG);
		test.show ();
	}
	
	
	public void onBackPressed () {
		Toast myToast = Toast.makeText (this, "Vergiss es!", Toast.LENGTH_SHORT);
		myToast.show ();
	}
	
	private Questionnaire importQuestions () {
		
		// read JSON file with GSON library
		// you have to add the dependency for gson
		// File > Project Structure > Add Dependency
		// TODO: invalid JSON still crashes the app!!!
		try {
			AssetManager assetManager = getAssets ();
			InputStream ims = assetManager.open ("example-questionnaire.json");
			
			Gson gson = new Gson ();
			Reader reader = new InputStreamReader (ims);
			
			Questionnaire quest = gson.fromJson (reader, Questionnaire.class);
			// test if read file :
			Toast success = Toast.makeText (this, "Alles erfolgreich eingelesen! Fragebogenname: \n" + quest.getName (), Toast.LENGTH_LONG);
			success.show ();
			return quest;
			
		}
		catch (IOException e) {
			e.printStackTrace ();
			// test if failed to read file :
			final StackTraceElement[] stackTrace = e.getStackTrace ();
			Toast failure = Toast.makeText (this, "Fehler beim Einlesen.\n" + Arrays.toString (stackTrace), Toast.LENGTH_LONG);
			failure.show ();
			return null;
		}
	}
	
	public void startButtonClick (View view) {
		if (this.currentQuestionnaire == null) {
			Toast toast = Toast.makeText (this, "Kein Fragebogen eingelesen.", Toast.LENGTH_SHORT);
			toast.show ();
			return;
		}
		QuestionnaireState questionnaireState = new QuestionnaireState (this.currentQuestionnaire);
		QuestionDisplayActivity.displayCurrentQuestion (questionnaireState, this);
		
	}
}
