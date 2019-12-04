package com.example.app;

import android.app.ActionBar;
import android.os.Bundle;
import android.os.Environment;
import android.support.v7.app.AppCompatActivity;
import android.view.Menu;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

import com.example.app.answer.Answer;
import com.google.gson.Gson;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.util.ArrayList;
import java.util.List;

public class SaveAnswersActivity extends AppCompatActivity {
	/*
	private List<Answer> aList;
	private int size;
	private List<String> answers;
	private String res;

	@Override
	protected void onCreate (Bundle savedInstanceState) {
		super.onCreate (savedInstanceState);
		setContentView (R.layout.activity_save_answers);
		Bundle more = getIntent ().getExtras ();
		assert more != null;
		res = "";
		size = more.getInt ("size", 0);
		aList = new ArrayList<> (size);
		answers = new ArrayList<> (size);
		// get answers from intent
		for (int i = 0; i < size; i++) {
			aList.add ((Answer) more.getSerializable ("a" + i));
			answers.add ("");
		}
		// save to answer list
		for (int j = 0; j < aList.size (); j++) {
			for (int k = 0; k < aList.get (j).getChosenValues ().size (); k++) {
				if (k == 0) {
					answers.set (j, aList.get (j).getChosenValues ().get (k).toString ());
				}
				else {
					answers.set (j, answers.get (j) + "," + aList.get (j).getChosenValues ().get (k));
				}
			}
		}
		// show user his answers for failsafe
		for (int i = 0; i < answers.size (); i++) {
			res += "Frage " + (i + 1) + " Antwort " + answers.get (i) + "\n";
		}
		TextView tv = findViewById (R.id.textViewres);
		tv.setText (res);//Wieso startet die activity nicht???????
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

	public void onBackPressed () {
		Toast myToast = Toast.makeText (this, "Vergiss es!", Toast.LENGTH_SHORT);
		myToast.show ();
	}

	//save to json without format
	public void saveButtonClick (View view) {
		Gson gson = new Gson ();
		//Text of the Document
		String textToWrite = gson.toJson (res);

		//Checking the availability state of the External Storage.
		String state = Environment.getExternalStorageState ();
		if (!Environment.MEDIA_MOUNTED.equals (state)) {

			//If it isn't mounted - we can't write into it.
			return;
		}

		//Create a new file that points to the root directory, with the given name:
		File file = new File (getExternalFilesDir (null), "questions.json");

		//This point and below is responsible for the write operation
		try {
			file.createNewFile ();
			BufferedWriter writer = new BufferedWriter (new FileWriter (file));
			writer.write (textToWrite);

			writer.close ();
			Toast myToast = Toast.makeText (this, "Gespeichert!", Toast.LENGTH_SHORT);
			myToast.show ();
		}
		catch (Exception e) {
			e.printStackTrace ();
			Toast myToast = Toast.makeText (this, "Nicht Gespeichert!", Toast.LENGTH_SHORT);
			myToast.show ();
		}
	}
	*/
}

