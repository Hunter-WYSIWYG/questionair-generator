package com.example.app;

import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.widget.Button;
import android.widget.TextView;

public class QuestionnaireFinishedActivity extends AppCompatActivity {
	
	private Button backToStart;
	
	@Override
	protected void onCreate (Bundle savedInstanceState) {
		super.onCreate (savedInstanceState);
		setContentView (R.layout.activity_questionnaire_finished);
		
		String answerList = this.getIntent ().getStringExtra ("EXTRA_ANSWERS");
		TextView text = this.findViewById (R.id.textView);
		text.setText (answerList);
		this.backToStart = this.findViewById (R.id.backToStartButton);
		this.backToStart.setOnClickListener (v -> this.goBackToStart ());
	}
	
	// go to main activity
	private void goBackToStart () {
		Intent intent = new Intent (this, MainActivity.class);
		startActivity (intent);
		finish ();
	}
	
	// create popup if back button is pressed
	public void onBackPressed () {
		AlertDialog.Builder alertDialog = new AlertDialog.Builder (this);
		alertDialog.setTitle ("");
		alertDialog.setMessage ("Wollen Sie den Fragebogen verlassen?");
		alertDialog.setCancelable (true);
		alertDialog.setPositiveButton (
			"Ja",
			new DialogInterface.OnClickListener () {
				public void onClick (DialogInterface dialog, int id) {
					dialog.cancel ();
					Intent intent = new Intent (QuestionnaireFinishedActivity.this, MainActivity.class);
					startActivity (intent);
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
}
