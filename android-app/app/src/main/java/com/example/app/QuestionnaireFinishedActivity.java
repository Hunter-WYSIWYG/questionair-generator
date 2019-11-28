package com.example.app;

import android.content.Intent;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.widget.Button;

public class QuestionnaireFinishedActivity extends AppCompatActivity {

	private Button backToStart;

	@Override
	protected void onCreate (Bundle savedInstanceState) {
		super.onCreate (savedInstanceState);
		setContentView(R.layout.activity_questionnaire_finished);
		
		backToStart = findViewById(R.id.backToStartButton);
		backToStart.setOnClickListener(v -> goBackToStart());
	}

	// go to main activity
	private void goBackToStart() {
		Intent intent = new Intent(this, MainActivity.class);
		startActivity(intent);
		finish();
	}
}
