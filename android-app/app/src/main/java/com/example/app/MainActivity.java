package com.example.app;

import android.app.ActionBar;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.res.AssetManager;
import android.os.Build;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.design.widget.NavigationView;
import android.support.constraint.ConstraintLayout;
import android.support.v4.app.NotificationCompat;
import android.support.v4.view.GravityCompat;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBarDrawerToggle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.text.format.DateFormat;
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
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.List;

public class MainActivity extends AppCompatActivity implements NavigationView.OnNavigationItemSelectedListener {
	// list of all questionnaires
	private final Collection<Questionnaire> questionnaireList = new ArrayList<>();
	
	private DrawerLayout drawerlayout;
	// list view of all questionnaires
	private ListView listView;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);
		Toolbar toolbar = findViewById(R.id.toolbar);
		setSupportActionBar(toolbar);
		drawerlayout = findViewById(R.id.drawer_layout);
		NavigationView navView = findViewById(R.id.nav_view);
		navView.setNavigationItemSelectedListener(this);
		ActionBarDrawerToggle toggle = new ActionBarDrawerToggle(this, drawerlayout, toolbar, R.string.navigation_drawer_open, R.string.navigation_drawer_close);
		drawerlayout.addDrawerListener(toggle);
		toggle.syncState();
		
		// number of questionnaires
		int x = 3;
		
		// import all questionnaires - just for testing
		// TODO how many questionnaires do we import???
		for (int i = 0; i <= x; i++) {
			questionnaireList.add(importQuestions(i));
		}
		init();
	}
	
	// init list
	public void init() {
		// list of string needed for arrayAdapter
		List<String> data = new ArrayList<>();
		for (Questionnaire questionnaire : questionnaireList) {
			data.add(questionnaire.getName());
		}
		// list view
		listView = findViewById(R.id.listView);
		// adapter for handling list view
		final ListAdapter adapter = new ArrayAdapter<>(this, android.R.layout.simple_list_item_activated_1, data);
		listView.setAdapter(adapter);
		// on click listener
		listView.setOnItemClickListener((parent, view, position, id) -> Toast.makeText(getApplicationContext(), "Click ListItem Number " + position, Toast.LENGTH_LONG).show());
	}
	
	private Questionnaire importQuestions(int index) {
		// read JSON file with GSON library
		// you have to add the dependency for gson
		// File > Project Structure > Add Dependency
		// TODO: invalid JSON still crashes the app!!!
		try {
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
		}
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
		if (drawerlayout.isDrawerOpen(GravityCompat.START)) {
			drawerlayout.closeDrawer(GravityCompat.START);
			return;
		}
		Toast myToast = Toast.makeText(this, "Vergiss es!", Toast.LENGTH_SHORT);
		myToast.show();
	}
	
	public void startButtonClick(View view) {
		// chosen questionnaire that the user will answer
		final Questionnaire currentQuestionnaire = setCurrentQuestionnaire();
		if (currentQuestionnaire == null) {
			Toast toast = Toast.makeText(this, "Kein Fragebogen eingelesen.", Toast.LENGTH_SHORT);
			toast.show();
			return;
		}
		QuestionnaireState questionnaireState = new QuestionnaireState(currentQuestionnaire);
		QuestionDisplayActivity.displayCurrentQuestion(questionnaireState, this);
	}
	
	public Questionnaire setCurrentQuestionnaire() {
		int position = listView.getCheckedItemPosition();
		for (Questionnaire questionnaire : questionnaireList) {
			if ((int) questionnaire.getID() == position) {
				return questionnaire;
			}
		}
		return null;
	}
	
	public void notifyButtonClick(View view) {
		// notifications
		Intent intent = new Intent(this, MainActivity.class);
		intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
		PendingIntent pendingIntent = PendingIntent.getActivity(this, 0, intent, 0);
		
		NotificationManager notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
		
		NotificationCompat.Builder builder;
		int currentApiVersion = android.os.Build.VERSION.SDK_INT;
		if (currentApiVersion <= Build.VERSION_CODES.N_MR1) {
			//noinspection deprecation
			builder = new NotificationCompat.Builder(this);
		} else {
			String channelId = "Fragebogen";
			NotificationChannel notificationChannel = new NotificationChannel(channelId, "My Notifications", NotificationManager.IMPORTANCE_DEFAULT);
			notificationManager.createNotificationChannel(notificationChannel);
			builder = new NotificationCompat.Builder(this, channelId);
		}
		Notification notify = builder.setContentTitle("type").setContentText("text").setSmallIcon(R.drawable.ic_launcher_foreground).setContentIntent(pendingIntent).build();
		
		assert (notificationManager != null);
		notificationManager.notify(0, notify);
		
		// testing
		Toast toast = Toast.makeText(this, "API " + currentApiVersion, Toast.LENGTH_SHORT);
		toast.show();
	}
	
	@Override
	public boolean onNavigationItemSelected(@NonNull final MenuItem menuItem) {
		switch (menuItem.getItemId()) {
			case R.id.nav_home:
				getSupportFragmentManager().popBackStackImmediate();
				break;
			case R.id.nav_licence:
				getSupportFragmentManager().beginTransaction().replace(R.id.fragment_container, new LicenceFragment()).addToBackStack(null).commit();
				break;
			default:
				break;
		}
		drawerlayout.closeDrawer(GravityCompat.START);
		return true;
	}
}
