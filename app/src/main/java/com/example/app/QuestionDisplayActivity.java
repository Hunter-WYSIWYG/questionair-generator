package com.example.app;

import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.widget.Toast;

import java.util.ArrayList;
import java.util.List;

public class QuestionDisplayActivity extends AppCompatActivity {
	private int current;
	private List<Question> list;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate( savedInstanceState );
		setContentView( R.layout.activity_question_display );
		
		Bundle extras = getIntent().getExtras();
		assert extras != null;
		current = extras.getInt( "current", -1 );
		int size = extras.getInt( "size", 0 );
		list = new ArrayList<>( size );
		for ( int i = 0; i < size; i++ ) {
			list.add( (Question) extras.getSerializable( "q" + i ) );
		}
		
		Toast toast = Toast.makeText( this, "result: " + current + ", " + list.size() + ", " + list.get( 0 ).getTitle(), Toast.LENGTH_LONG );
		toast.show();
		
		Question currentQ = list.get(current);
		
	}
}
