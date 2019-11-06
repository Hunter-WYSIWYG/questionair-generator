package com.example.app.question;

import com.google.gson.*;
import com.google.gson.annotations.JsonAdapter;
import com.google.gson.annotations.SerializedName;

import java.io.Serializable;
import java.lang.reflect.Type;
import java.util.Collections;
import java.util.Date;
import java.util.List;


// Question uses id and type
@JsonAdapter (ReminderAdapter.class) // -> using QuestionAdapter to convert from or to JSON
public class Reminder implements Serializable {
	@SerializedName ("date")
	public final String date;
	@SerializedName ("reminderText")
	public final String reminderText;
	
	// constructor
	public Reminder (String date, String reminderText) {
		this.date = date;
		this.reminderText = reminderText;
	}
	
}

