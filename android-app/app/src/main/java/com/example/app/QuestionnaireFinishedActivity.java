package com.example.app;

import android.content.Intent;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.widget.Button;
import android.widget.TextView;

public class QuestionnaireFinishedActivity extends AppCompatActivity {
	
	private Button backToStart;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_questionnaire_finished);
		
		String answerList = getIntent().getStringExtra("EXTRA_ANSWERS");
		TextView text = findViewById(R.id.textView);
		text.setText(answerList);
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
