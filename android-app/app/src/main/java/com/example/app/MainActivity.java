package com.example.app;

import android.app.ActionBar;
import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.res.AssetManager;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.design.widget.NavigationView;
import android.support.v4.view.GravityCompat;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBarDrawerToggle;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.ListAdapter;
import android.widget.ListView;
import android.widget.Toast;

import com.example.app.question.Questionnaire;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.util.*;

public class MainActivity extends AppCompatActivity implements NavigationView.OnNavigationItemSelectedListener {
	// list of all questionnaires
	private final List<Questionnaire> questionnaireList = new ArrayList<> ();
	
	private DrawerLayout drawerlayout;
	// list view of all questionnaires
	private ListView listView;
	
	@Override
	protected void onCreate (Bundle savedInstanceState) {
		super.onCreate (savedInstanceState);
		setContentView (R.layout.activity_main);
		Toolbar toolbar = findViewById (R.id.toolbar);
		setSupportActionBar (toolbar);
		this.drawerlayout = findViewById (R.id.drawer_layout);
		NavigationView navView = findViewById (R.id.nav_view);
		navView.setNavigationItemSelectedListener (this);
		ActionBarDrawerToggle toggle = new ActionBarDrawerToggle (this, drawerlayout, toolbar, R.string.navigation_drawer_open, R.string.navigation_drawer_close);
		this.drawerlayout.addDrawerListener (toggle);
		toggle.syncState ();
		
		// TODO import all questionnaires and not just a given number of them
		for (int i = 0; i <= 3; i++) {
			Questionnaire questionnaire = this.importQuestionnaire (i);
			if (questionnaire != null)
				this.questionnaireList.add (questionnaire);
		}
		this.notifyStart ();
		this.init ();
	}
	
	// init list
	public void init () {
		// questionnaires have to be sorted before the list view of them is generated
		this.sortQuestionnaires ();

		// list of string needed for arrayAdapter
		List<String> data = new ArrayList<> ();
		for (Questionnaire questionnaire : this.questionnaireList) {
			data.add (questionnaire.getName ());
		}
		// list view
		this.listView = findViewById (R.id.listView);
		// adapter for handling list view
		final ListAdapter adapter = new ArrayAdapter<> (this, android.R.layout.simple_list_item_activated_1, data);
		this.listView.setAdapter (adapter);
	}
	
	private Questionnaire importQuestionnaire (int index) {
		// read JSON file with GSON library
		// you have to add the dependency for gson
		// File > Project Structure > Add Dependency
		// TODO: invalid JSON still crashes the app!!!
		try {
			AssetManager assetManager = getAssets ();
			InputStream ims = assetManager.open ("schema-test-2.json");
			Gson gson = new GsonBuilder ().setDateFormat ("yyyy-MM-dd'T'HH:mm:ssXXX").create ();
			Reader reader = new InputStreamReader (ims);
			return gson.fromJson (reader, Questionnaire.class);
		}
		catch (IOException e) {
			e.printStackTrace ();
			// test if failed to read file :
			final StackTraceElement[] stackTrace = e.getStackTrace ();
			Toast failure = Toast.makeText (this, "Fehler beim Einlesen.\n" + Arrays.toString (stackTrace), Toast.LENGTH_LONG);
			failure.show ();
			return null;
		}
		
		/*try {
			AssetManager assetManager = getAssets();
			InputStream ims = assetManager.open("example-questionnaire-" + index + ".json");
			
			Gson gson = new GsonBuilder().setDateFormat("yyyy-MM-dd'T'HH:mm:ssXXX").create();
			Reader reader = new InputStreamReader(ims);
			
			return gson.fromJson(reader, Questionnaire.class);
		}
		catch (IOException e) {
			e.printStackTrace();
			// test if failed to read file :
			final StackTraceElement[] stackTrace = e.getStackTrace();
			Toast failure = Toast.makeText(this, "Fehler beim Einlesen.\n" + Arrays.toString(stackTrace), Toast.LENGTH_LONG);
			failure.show();
			return null;
		} */
	}
	
	public boolean onCreateOptionsMenu (Menu menu) {
		ActionBar actionBar = getActionBar ();
		if (actionBar != null) {
			actionBar.setHomeButtonEnabled (false);      // Disable the button
			actionBar.setDisplayHomeAsUpEnabled (false); // Remove the left caret
			actionBar.setDisplayShowHomeEnabled (false); // Remove the icon
		}
		return true;
	}
	
	// create popup if back button is pressed
	public void onBackPressed () {
		if (this.drawerlayout.isDrawerOpen (GravityCompat.START)) {
			this.drawerlayout.closeDrawer (GravityCompat.START);
			return;
		}
		AlertDialog.Builder alertDialog = new AlertDialog.Builder (this);
		alertDialog.setTitle ("");
		alertDialog.setMessage ("Wollen Sie die App verlassen?");
		alertDialog.setCancelable (true);
		alertDialog.setPositiveButton (
			"Ja",
			new DialogInterface.OnClickListener () {
				public void onClick (DialogInterface dialog, int id) {
					dialog.cancel ();
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
	
	public void startButtonClick (View view) {
		// chosen questionnaire that the user will answer
		final Questionnaire currentQuestionnaire = getCurrentQuestionnaire();
		if (currentQuestionnaire == null) {
			Toast toast = Toast.makeText (this, "Kein Fragebogen eingelesen.", Toast.LENGTH_SHORT);
			toast.show ();
			return;
		}
		QuestionnaireState questionnaireState = new QuestionnaireState (currentQuestionnaire);
		QuestionDisplayActivity.displayCurrentQuestion (questionnaireState, this);
	}
	
	public Questionnaire getCurrentQuestionnaire() {
		int position = this.listView.getCheckedItemPosition ();
		if (position >= 0 && position < this.questionnaireList.size())
			return this.questionnaireList.get (position);
		else
			return null;
	}
	
	public void notifyStart () {
		//use all reminders
		int reminderNumber = 0;
		Date now = new Date (System.currentTimeMillis ());
		for (Questionnaire questionnaire : this.questionnaireList) {
			for (Date reminderDate : questionnaire.getReminderList ()) {
				if (reminderDate.after (now)) {
					Intent alarmIntent = new Intent (this, AlarmReceiver.class);
					alarmIntent.putExtra("questionnaire", questionnaire.getName());
					alarmIntent.putExtra("remindernmb", reminderNumber);
					PendingIntent pendingIntent = PendingIntent.getBroadcast (this, reminderNumber, alarmIntent, PendingIntent.FLAG_UPDATE_CURRENT);
					AlarmManager manager = (AlarmManager) getSystemService (Context.ALARM_SERVICE);

					Calendar calendar = Calendar.getInstance ();
					calendar.setTime (reminderDate);
					manager.set (AlarmManager.RTC_WAKEUP, calendar.getTimeInMillis (), pendingIntent);
					reminderNumber++;
				}
			}
		}
	}
	
	@Override
	public boolean onNavigationItemSelected (@NonNull final MenuItem menuItem) {
		switch (menuItem.getItemId ()) {
			case R.id.nav_home:
				getSupportFragmentManager ().popBackStackImmediate ();
				break;
			case R.id.nav_licence:
				getSupportFragmentManager ().beginTransaction ().replace (R.id.fragment_container, new LicenceFragment ()).addToBackStack (null).commit ();
				break;
			default:
				break;
		}
		this.drawerlayout.closeDrawer (GravityCompat.START);
		return true;
	}
	
	// sort questionnaires by priority
	public void sortQuestionnaires () {
		Collections.sort(this.questionnaireList, new Comparator<Questionnaire> () {
			@Override
			public int compare(Questionnaire q1, Questionnaire q2) {
				return q1.getPriority () - q2.getPriority ();
			}
		});
	}
}