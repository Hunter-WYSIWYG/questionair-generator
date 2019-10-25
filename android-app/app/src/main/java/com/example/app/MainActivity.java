package com.example.app;

import android.app.ActionBar;
import android.content.res.AssetManager;
import android.os.Bundle;
import android.support.v4.view.GravityCompat;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBarDrawerToggle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.Menu;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

import com.example.app.question.Questionnaire;
import com.google.gson.Gson;

import org.jetbrains.annotations.Nullable;

import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.util.Arrays;

public class MainActivity extends AppCompatActivity {
	private DrawerLayout drawerlayout;
	
	private Questionnaire questionnaire = null;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);
		Toolbar toolbar = findViewById(R.id.toolbar);
		setSupportActionBar(toolbar);
		drawerlayout = findViewById(R.id.drawer_layout);
		ActionBarDrawerToggle toggle = new ActionBarDrawerToggle(this,drawerlayout,toolbar,R.string.navigation_drawer_open,R.string.navigation_drawer_close);
		drawerlayout.addDrawerListener(toggle);
		toggle.syncState();
		
		
		questionnaire = importQuestions();
		TextView tv = findViewById(R.id.dynamicQname);
		tv.setText(questionnaire.getName());
	}
	
	public boolean onCreateOptionsMenu(Menu menu) {
		ActionBar actionBar = getActionBar();
		if (null != actionBar) {
			actionBar.setHomeButtonEnabled(false);      // Disable the button
			actionBar.setDisplayHomeAsUpEnabled(false); // Remove the left caret
			actionBar.setDisplayShowHomeEnabled(false); // Remove the icon
		}
		return true;
	}
	
	public void onBackPressed() {
		if(drawerlayout.isDrawerOpen(GravityCompat.START)) {
			drawerlayout.closeDrawer(GravityCompat.START);
			return;
		}
		Toast myToast = Toast.makeText(this, "Vergiss es!", Toast.LENGTH_SHORT);
		myToast.show();
	}
	
	@Nullable
	private Questionnaire importQuestions() {
		
		// read JSON file with GSON library
		// you have to add the dependency for gson
		// File > Project Structure > Add Dependency
		// TODO: invalid JSON still crashes the app!!!
		try {
			AssetManager assetManager = getAssets();
			InputStream ims = assetManager.open("example-questionnaire.json");
			
			Gson gson = new Gson();
			Reader reader = new InputStreamReader(ims);
			
			Questionnaire quest = gson.fromJson(reader, Questionnaire.class);
			// test if read file :
			Toast success = Toast.makeText(this, "Alles erfolgreich eingelesen! Fragebogenname: \n" + quest.getName(), Toast.LENGTH_LONG);
			success.show();
			return quest;
			
		}
		catch (IOException e) {
			e.printStackTrace();
			// test if failed to read file :
			final StackTraceElement[] stackTrace = e.getStackTrace();
			Toast failure = Toast.makeText(this, "Fehler beim Einlesen.\n" + Arrays.toString(stackTrace), Toast.LENGTH_LONG);
			failure.show();
			return null;
		}
	}
	
	public void startButtonClick(View view) {
		if (null == questionnaire) {
			Toast toast = Toast.makeText(this, "Kein Fragebogen eingelesen.", Toast.LENGTH_SHORT);
			toast.show();
			return;
		}
		QuestionnaireState questionnaireState = new QuestionnaireState(questionnaire);
		QuestionDisplayActivity.displayCurrentQuestion(questionnaireState, this);
		
	}
}
