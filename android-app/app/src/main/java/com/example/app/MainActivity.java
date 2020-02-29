package com.example.app;

import android.app.ActionBar;
import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.res.AssetManager;
import android.os.Bundle;
import android.os.Environment;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
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

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.List;

public class MainActivity extends AppCompatActivity implements NavigationView.OnNavigationItemSelectedListener {
	// list of all questionnaires
	private final List<Questionnaire> questionnaireList = new ArrayList<>();
	
	private DrawerLayout drawerlayout;
	// list view of all questionnaires
	private ListView listView;
	
	// saved user name
	public static String username = "";
	
	public static final String questionnaireDirName = "fragebogen";
	public static final String answersDirName = "antworten";
	@Nullable
	@SuppressWarnings("StaticNonFinalField")
	public static File FILES_DIR;
	@Nullable
	@SuppressWarnings("StaticNonFinalField")
	public static File QUESTIONNAIRE_DIR;
	@Nullable
	@SuppressWarnings("StaticNonFinalField")
	public static File ANSWERS_DIR;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);
		Toolbar toolbar = findViewById(R.id.toolbar);
		setSupportActionBar(toolbar);
		this.drawerlayout = findViewById(R.id.drawer_layout);
		NavigationView navView = findViewById(R.id.nav_view);
		navView.setNavigationItemSelectedListener(this);
		ActionBarDrawerToggle toggle = new ActionBarDrawerToggle(this, drawerlayout, toolbar, R.string.navigation_drawer_open, R.string.navigation_drawer_close);
		this.drawerlayout.addDrawerListener(toggle);
		toggle.syncState();
		
		switch (this.firstTimeSetup()) {
			case 0:
				// first time setup files already exist, skip
				break;
			case 1:
				// first time setup files have been created
				// move questionnaires from asset folder to new folder on the phone
				if (!this.moveQuestionnaires()) {
					Toast.makeText(this, "Willkommen zu der Umfragebogen-App! Die Speicherordner wurden erzeugt, aber nicht beschrieben", Toast.LENGTH_LONG).show();
				} else {
					Toast.makeText(this, "Willkommen zu der Umfragebogen-App! Die Speicherordner wurden erzeugt und beschrieben", Toast.LENGTH_LONG).show();
				}
				break;
			case -1:
				// first time setup files have not been created, something went wrong
				Toast.makeText(this, "Die Speicherordner wurden nicht erzeugt! Bitte versuchen sie es erneut", Toast.LENGTH_LONG).show();
				break;
			default:
				break;
		}
		
		if (getPreferenceValue().equals("")) {
			UsernameFragment.changeUsernameDialog(this);
		}
		
		this.importQuestionnaires();
		// delete questionnaires which are not in the viewing time
		try {
			this.checkViewingTime();
		} catch (ParseException e) {
			e.printStackTrace();
		}
		this.notifyStart();
		this.init();
	}
	
	// first time setting up the answers and questionnaires directories
	private int firstTimeSetup() {
		// Checking the availability state of the External Storage.
		String state = Environment.getExternalStorageState();
		if (!Environment.MEDIA_MOUNTED.equals(state)) {
			//If it isn't mounted - we can't write into it.
			return -1;
		}
		
		// get current files path
		// noinspection AssignmentToStaticFieldFromInstanceMethod
		FILES_DIR = getExternalFilesDir(null);
		
		// assign path to variables, check if already assigned variable is good
		if (QUESTIONNAIRE_DIR == null) {
			//noinspection AssignmentToStaticFieldFromInstanceMethod
			QUESTIONNAIRE_DIR = new File(FILES_DIR, questionnaireDirName);
		}
		
		if (ANSWERS_DIR == null) {
			// noinspection AssignmentToStaticFieldFromInstanceMethod
			ANSWERS_DIR = new File(FILES_DIR, answersDirName);
		}
		
		// check if both directories exist
		boolean qExists = QUESTIONNAIRE_DIR.exists();
		boolean aExists = ANSWERS_DIR.exists();
		
		if (qExists && aExists) {
			// both exist, exit fast
			return 0;
		}
		
		// one or both do not exist, create new
		if (!qExists) {
			boolean createSuccess = QUESTIONNAIRE_DIR.mkdir();
			if (!createSuccess) {
				// could not create folder, something went wrong
				return -1;
			}
		}
		if (!aExists) {
			boolean createSuccess = ANSWERS_DIR.mkdir();
			if (!createSuccess) {
				// could not create folder, something went wrong
				return -1;
			}
		}
		
		// newly created folders, return status for success
		return 1;
	}
	
	// moves all questionnaires from the asset folder to the questionnaire folder on the phone
	private boolean moveQuestionnaires() {
		// do NOT close() the assetManager, causes app crash
		AssetManager assetManager = getAssets();
		try {
			final String[] arr = assetManager.list("");
			if (arr == null) {
				//no files found, nothing to do
				return true;
			}
			// for each file...
			for (String str : arr) {
				// must end on .json
				if (!str.endsWith(".json")) {
					// just go to the next one
					continue;
				}
				// result file location
				final File destFile = new File(QUESTIONNAIRE_DIR, str);
				if (!destFile.createNewFile()) {
					if (!destFile.isFile()) {
						return false;
					}
					if (destFile.delete()) {
						if (!destFile.createNewFile()) {
							return false;
						}
					} else {
						return false;
					}
				}
				// reader and writer
				try (BufferedReader reader = new BufferedReader(new InputStreamReader(assetManager.open(str, AssetManager.ACCESS_STREAMING)))) {
					try (BufferedWriter writer = new BufferedWriter(new FileWriter(destFile))) {
						// reading to StringBuilder
						// see https://www.baeldung.com/java-write-reader-to-file
						final StringBuilder builder = new StringBuilder();
						int intValueOfChar = reader.read();
						while (intValueOfChar != -1) {
							builder.append((char) intValueOfChar);
							intValueOfChar = reader.read();
						}
						// write to file
						writer.write(builder.toString());
					}
				}
			}
			return true;
		}
		catch (IOException e) {
			e.printStackTrace();
			return false;
		}
	}
	
	// init list
	public void init() {
		// questionnaires have to be sorted before the list view of them is generated
		this.sortQuestionnaires();
		
		// list of string needed for arrayAdapter
		List<String> data = new ArrayList<>();
		for (Questionnaire questionnaire : questionnaireList) {
			final String name = questionnaire.getName();
			if (name == null) {
				data.add("null");
			} else {
				data.add(name);
			}
		}
		// list view
		this.listView = findViewById(R.id.listView);
		// adapter for handling list view
		final ListAdapter adapter = new ArrayAdapter<>(this, android.R.layout.simple_list_item_activated_1, data);
		this.listView.setAdapter(adapter);
	}
	
	// sort questionnaires by priority
	public void sortQuestionnaires() {
		Collections.sort(this.questionnaireList, (q1, q2) -> Integer.compare(q1.getPriority(), q2.getPriority()));
	}

	public void checkViewingTime () throws ParseException {
		List<Questionnaire> deleteFromQuestionnaire = new ArrayList<>();
		for (Questionnaire quest : this.questionnaireList) {
			if (quest.getViewingTime() != null) {
				if (!quest.getViewingTime().equals("")) {
					String[] parts = quest.getViewingTime().split(";");
					Date start = new SimpleDateFormat("dd-MM-yyyy").parse(parts[0]);
					Date end = new SimpleDateFormat("dd-MM-yyyy").parse(parts[1]);
					Date today = Calendar.getInstance().getTime();

					boolean isTodayBetweenStartAndEnd = ((today.after(start)) && (today.before(end)));
					if (!isTodayBetweenStartAndEnd) {
						deleteFromQuestionnaire.add(quest);
					}
				}
			}
		}
		for (Questionnaire q : deleteFromQuestionnaire) {
			this.questionnaireList.remove(q);

		}
	}
	
	private void importQuestionnaires() {
		try {
			Gson gson = new GsonBuilder().setDateFormat("yyyy-MM-dd'T'HH:mm:ssXXX").create();
			// look at all files in the questionnaire directory
			assert QUESTIONNAIRE_DIR != null;
			final File[] foundFiles = QUESTIONNAIRE_DIR.listFiles();
			for (File file : foundFiles) {
				// only look at .json files
				if (!file.isFile() || !file.getPath().endsWith(".json")) {
					continue;
				}
				// read files and add to list
				try (BufferedReader reader = new BufferedReader(new FileReader(file))) {
					Questionnaire questionnaire;
					try {
						questionnaire = gson.fromJson(reader, Questionnaire.class);
					}
					catch (Exception e) {
						continue;
					}
					// questionnaires must have positive id, otherwise error is assumed (default constructor writes -1)
					if (questionnaire.getID() >= 0) {
						questionnaireList.add(questionnaire);
					}
				}
			}
		}
		catch (IOException e) {
			e.printStackTrace();
		}
	}
	
	public void notifyStart() {
		//use all reminders
		int reminderNumber = 0;
		Date now = new Date(System.currentTimeMillis());
		for (Questionnaire questionnaire : this.questionnaireList) {
			for (Date reminderDate : questionnaire.getReminderList()) {
				if (reminderDate.after(now)) {
					Intent alarmIntent = new Intent(this, AlarmReceiver.class);
					alarmIntent.putExtra("questionnaire", questionnaire.getName());
					alarmIntent.putExtra("remindernmb", reminderNumber);
					PendingIntent pendingIntent = PendingIntent.getBroadcast(this, reminderNumber, alarmIntent, PendingIntent.FLAG_UPDATE_CURRENT);
					AlarmManager manager = (AlarmManager) getSystemService(Context.ALARM_SERVICE);
					
					Calendar calendar = Calendar.getInstance();
					calendar.setTime(reminderDate);
					manager.set(AlarmManager.RTC_WAKEUP, calendar.getTimeInMillis(), pendingIntent);
					reminderNumber++;
				}
			}
		}
	}
	
	// change shared preference settings
	public String getPreferenceValue() {
		SharedPreferences sp = getSharedPreferences(username, 0);
		return sp.getString("key", "");
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
	
	// create popup if back button is pressed
	public void onBackPressed() {
		if (this.drawerlayout.isDrawerOpen(GravityCompat.START)) {
			this.drawerlayout.closeDrawer(GravityCompat.START);
			return;
		}
		AlertDialog.Builder alertDialog = new AlertDialog.Builder(this);
		alertDialog.setTitle("");
		alertDialog.setMessage("Wollen Sie die App verlassen?");
		alertDialog.setCancelable(true);
		alertDialog.setPositiveButton("Ja", (dialog, id) -> {
			dialog.cancel();
			finish();
		});
		alertDialog.setNegativeButton("Abbrechen", (dialog, id) -> dialog.cancel());
		AlertDialog alert = alertDialog.create();
		alert.show();
	}
	
	@Override
	public boolean onNavigationItemSelected(@NonNull final MenuItem menuItem) {
		while (getSupportFragmentManager().getBackStackEntryCount() > 0) {
			getSupportFragmentManager().popBackStackImmediate();
		}
		switch (menuItem.getItemId()) {
			case R.id.nav_username:
				getSupportFragmentManager().beginTransaction().replace(R.id.fragment_container, new UsernameFragment()).addToBackStack(null).commit();
				break;
			case R.id.nav_licence:
				getSupportFragmentManager().beginTransaction().replace(R.id.fragment_container, new LicenceFragment()).addToBackStack(null).commit();
				break;
			default:
				break;
		}
		this.drawerlayout.closeDrawer(GravityCompat.START);
		return true;
	}
	
	public void startButtonClick(View view) {
		// chosen questionnaire that the user will answer
		final Questionnaire currentQuestionnaire = getCurrentQuestionnaire();
		if (currentQuestionnaire == null) {
			Toast toast = Toast.makeText(this, "Kein Fragebogen eingelesen.", Toast.LENGTH_SHORT);
			toast.show();
			return;
		}
		QuestionnaireState questionnaireState = new QuestionnaireState(currentQuestionnaire);
		QuestionDisplayActivity.displayCurrentQuestion(questionnaireState, this);
	}
	
	public Questionnaire getCurrentQuestionnaire() {
		int position = this.listView.getCheckedItemPosition();
		if (position >= 0 && position < this.questionnaireList.size()) {
			return this.questionnaireList.get(position);
		} else {
			return null;
		}
	}
	
	public void writeToPreference(String thePreference) {
		SharedPreferences.Editor editor = getSharedPreferences(username, 0).edit();
		editor.putString("key", thePreference);
		editor.apply();
	}
	
	public void refreshButtonClick(View view) {
		questionnaireList.clear();
		importQuestionnaires();
		// delete questionnaires which are not in the viewing time
		try {
			this.checkViewingTime();
		} catch (ParseException e) {
			e.printStackTrace();
		}
		notifyStart();
		init();
	}
}