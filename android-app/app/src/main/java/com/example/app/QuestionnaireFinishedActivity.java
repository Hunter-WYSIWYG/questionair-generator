package com.example.app;

import android.content.Intent;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.widget.Button;
import android.widget.Toast;

import java.io.File;

public class QuestionnaireFinishedActivity extends AppCompatActivity {

	private Button backToStart;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_questionnaire_finished);

		final File externalFilesDir = getExternalFilesDir(null);
		if (externalFilesDir != null) {
			if (QuestionnaireState.save(externalFilesDir)) {
				Toast.makeText(this, "Gespeichert!", Toast.LENGTH_SHORT).show();
			} else {
				Toast.makeText(this, "Nicht Gespeichert!", Toast.LENGTH_SHORT).show();
			}
		} else {
			Toast.makeText(this, "Nicht Gespeichert!", Toast.LENGTH_SHORT).show();
		}

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
