package com.example.app.question;

import com.google.gson.annotations.SerializedName;

import java.io.Serializable;
import java.util.Date;


// Reminder has date and text
class Reminder implements Serializable {
	@SerializedName ("date")
	private final Date date;
	@SerializedName ("reminderText")
	private final String reminderText;
	
	// constructor
	public Reminder(Date date, String reminderText) {
		this.date = date;
		this.reminderText = reminderText;
	}
	
}

