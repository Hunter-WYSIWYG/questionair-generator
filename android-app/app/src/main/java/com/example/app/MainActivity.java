package com.example.app;

import android.app.*;
import android.content.Context;
import android.content.Intent;
import android.content.res.AssetManager;
import android.os.Bundle;
import android.support.constraint.ConstraintLayout;
import android.support.v4.app.NotificationCompat;
import android.support.v7.app.AppCompatActivity;
import android.text.format.DateFormat;
import android.view.Menu;
import android.view.View;
import android.widget.*;

import com.example.app.question.Question;
import com.example.app.question.Questionnaire;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class MainActivity extends AppCompatActivity {
	// chosen questionnaire that the user will answer
	private Questionnaire currentQuestionnaire = null;
	// list of all questionnaires
	private List<Questionnaire> questionnaireList = new ArrayList<> ();
	// list view of all questionnaires
	private ListView listView;
	
	@Override
	protected void onCreate (Bundle savedInstanceState) {
		super.onCreate (savedInstanceState);
		setContentView (R.layout.activity_main);
		
		// import all questionnaires - just for testing
		for (int i = 0; i < 20; i++) {
			this.questionnaireList.add (this.importQuestions ());
		}
		this.init ();
	}
	
	public boolean onCreateOptionsMenu (Menu menu) {
		ActionBar actionBar = getActionBar ();
		// TODO with navigation view
		return true;
	}
	
	// init list
	public void init () {
		// list of string needed for arrayAdapter
		List<String> data = new ArrayList<> ();
		for (Questionnaire questionnaire : this.questionnaireList) {
			data.add (questionnaire.getName ());
		}
		// list view
		this.listView = (ListView) findViewById (R.id.listView);
		// adapter for handling list view
		final ArrayAdapter adapter = new ArrayAdapter (this, android.R.layout.simple_list_item_activated_1, data);
		listView.setAdapter (adapter);
		// on click listener
		listView.setOnItemClickListener (new AdapterView.OnItemClickListener () {
			
			@Override
			public void onItemClick (AdapterView<?> parent, View view, int position, long id) {
				Toast.makeText (getApplicationContext (), "Click ListItem Number " + position, Toast.LENGTH_LONG).show ();
			}
			
		});
		
		
	}
	
	public Questionnaire setCurrentQuestionnaire () {
		int position = this.listView.getCheckedItemPosition ();
		for (Questionnaire questionnaire : this.questionnaireList) {
			if ((int) questionnaire.getID () == position) {
				return questionnaire;
			}
		}
		return null;
	}
	
	private Questionnaire importQuestions () {
		
		// read JSON file with GSON library
		// you have to add the dependency for gson
		// File > Project Structure > Add Dependency
		// TODO: invalid JSON still crashes the app!!!
		try {
			AssetManager assetManager = getAssets ();
			InputStream ims = assetManager.open ("example-questionnaire.json");
			
			Gson gson = new GsonBuilder ().setDateFormat("yyyy-MM-dd'T'HH:mm:ssXXX").create();
			Reader reader = new InputStreamReader (ims);
			
			Questionnaire questionnaire = gson.fromJson (reader, Questionnaire.class);
			
			return questionnaire;
			
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
		this.currentQuestionnaire = this.setCurrentQuestionnaire ();
		if (this.currentQuestionnaire == null) {
			Toast toast = Toast.makeText (this, "Kein Fragebogen eingelesen.", Toast.LENGTH_SHORT);
			toast.show ();
			return;
		}
		QuestionnaireState questionnaireState = new QuestionnaireState (this.currentQuestionnaire);
		QuestionDisplayActivity.displayCurrentQuestion (questionnaireState, this);
	}
	
	private void notifyButtonClick (View view) {
		// notifications
		Intent intent = new Intent(this, MainActivity.class);
		intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
		PendingIntent pendingIntent = PendingIntent.getActivity(this, 0, intent, 0);
		
		NotificationManager notificationManager = (NotificationManager) getSystemService (Context.NOTIFICATION_SERVICE);

		NotificationCompat.Builder builder;
		int currentApiVersion = android.os.Build.VERSION.SDK_INT;
		if (currentApiVersion <= 25) {
			builder = new NotificationCompat.Builder (this);
		} else {
			String channelId = "fragebogen";
			NotificationChannel notificationChannel = new NotificationChannel(channelId, "My Notifications", NotificationManager.IMPORTANCE_DEFAULT);
			notificationManager.createNotificationChannel(notificationChannel);
			builder = new NotificationCompat.Builder (this, channelId);
		}
		Notification notify = builder
				.setContentTitle("title")
				.setContentText("text")
				.setSmallIcon(R.drawable.ic_launcher_foreground)
				.setContentIntent (pendingIntent)
				.build ();
		
		notificationManager.notify (0, notify);
		
		// testing
		Toast toast = Toast.makeText (this, "API " + currentApiVersion, Toast.LENGTH_SHORT);
		toast.show ();
		
	}
}
