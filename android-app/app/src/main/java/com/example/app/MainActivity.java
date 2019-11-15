package com.example.app;

import android.app.*;
import android.content.Context;
import android.content.Intent;
import android.content.res.AssetManager;
import android.os.Bundle;
import android.support.v4.app.NotificationCompat;
import android.support.v7.app.AppCompatActivity;
import android.view.Menu;
import android.view.View;
import android.widget.*;

import com.example.app.question.Questionnaire;
import com.example.app.question.Reminder;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.util.*;

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
		
		// number of questionnaires
		int x = 3;
		
		// import all questionnaires - just for testing
		// TODO how many questionnaires do we import???
		for (int i = 0; i <= x; i++) {
			this.questionnaireList.add (this.importQuestions (i));
		}
		this.notifystart ();
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
	
	private Questionnaire importQuestions (int index) {
		
		// read JSON file with GSON library
		// you have to add the dependency for gson
		// File > Project Structure > Add Dependency
		// TODO: invalid JSON still crashes the app!!!
		try {
			AssetManager assetManager = getAssets ();
			InputStream ims = assetManager.open ("example-questionnaire-" + index + ".json");
			
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
	
	public void notifystart () {
		//use all reminders
		int reminder_number=0;
		Date datecheck = new Date(System.currentTimeMillis());
		for (Questionnaire questionnaire : this.questionnaireList) {
			for (Reminder reminder : questionnaire.getReminderList ()) {
				if(reminder.date.after (datecheck)) {
					Intent alarmIntent = new Intent (this, AlarmReceiver.class);
					alarmIntent.putExtra ("questionnaire", questionnaire.getName ());
					alarmIntent.putExtra ("reminder", reminder.reminderText);
					alarmIntent.putExtra ("remindernmb", reminder_number);
					PendingIntent pendingIntent = PendingIntent.getBroadcast (this, reminder_number, alarmIntent, PendingIntent.FLAG_UPDATE_CURRENT);
					AlarmManager manager = (AlarmManager) getSystemService (Context.ALARM_SERVICE);
					
					Calendar calendar = Calendar.getInstance ();
					calendar.setTime (reminder.date);
					manager.set (AlarmManager.RTC_WAKEUP, calendar.getTimeInMillis (), pendingIntent);
					reminder_number++;
				}
			}
		
		}
		Toast toast = Toast.makeText (this, " Notifications initiated", Toast.LENGTH_SHORT);
		toast.show ();
		
	}
	
}