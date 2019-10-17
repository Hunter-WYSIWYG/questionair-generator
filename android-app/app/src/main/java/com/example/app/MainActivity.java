package com.example.app;

import android.app.ActionBar;
import android.content.Intent;
import android.content.res.AssetManager;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.view.Menu;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

import com.example.app.question.Question;
import com.example.app.question.Questionnaire;
import com.google.gson.Gson;

import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.util.Arrays;
import java.util.List;

public class MainActivity extends AppCompatActivity {
	private Questionnaire questionnaire = null;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);
		questionnaire = importQuestions();
		TextView tv = findViewById(R.id.dynamicQname);
		tv.setText(questionnaire.getName());
	}
	
	public boolean onCreateOptionsMenu(Menu menu) {
		ActionBar actionBar = getActionBar();
		if (actionBar != null) {
			actionBar.setHomeButtonEnabled(false);      // Disable the button
			actionBar.setDisplayHomeAsUpEnabled(false); // Remove the left caret
			actionBar.setDisplayShowHomeEnabled(false); // Remove the icon
		}
		return true;
	}
	
	public void onBackPressed() {
		Toast myToast = Toast.makeText(this, "Vergiss es!", Toast.LENGTH_SHORT);
		myToast.show();
	}
	
	private Questionnaire importQuestions() {
		
		// read JSON file with GSON library
		// you have to add the dependency for gson
		// File > Project Structure > Add Dependency
		try {
			AssetManager assetManager = getAssets();
			InputStream ims = assetManager.open("example-questionnaire.json");
			
			Gson gson = new Gson();
			Reader reader = new InputStreamReader(ims);
			
			Questionnaire quest = gson.fromJson(reader, Questionnaire.class);
			// test if read file :
			Toast success = Toast.makeText(this, "Alles erfolgreich eingelesen! Fragebogenname: " + quest.getName(), Toast.LENGTH_LONG);
			success.show();
			return quest;
			
		} catch (IOException e) {
			e.printStackTrace();
			// test if failed to read file :
			final StackTraceElement[] stackTrace = e.getStackTrace();
			Toast failure = Toast.makeText(this, "Fehler beim Einlesen.\n" + Arrays.toString(stackTrace), Toast.LENGTH_LONG);
			failure.show();
			return null;
		}
	}
	
	public void startButtonClick(View view) {
		if (questionnaire == null) {
			Toast toast = Toast.makeText(this, "questionnaire was null", Toast.LENGTH_SHORT);
			toast.show();
			return;
		}
		List<Question> list = questionnaire.getQuestionList();
		if (list == null) {
			Toast toast = Toast.makeText(this, "list was null", Toast.LENGTH_SHORT);
			toast.show();
			return;
		}
		Intent i = new Intent(this, QuestionDisplayActivity.class);
		i.putExtra("size", list.size());
		i.putExtra("current", 0);
		for (int j = 0; j < list.size(); j++) {
			i.putExtra("questionnaire" + j, list.get(j));
			i.putExtra("a" + j, (String) null);
		}
		startActivity(i);
	}
}
