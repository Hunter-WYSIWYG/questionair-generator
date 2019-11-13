package com.example.app.question;

import com.google.gson.*;
import com.google.gson.annotations.JsonAdapter;
import com.google.gson.annotations.SerializedName;

import java.io.Serializable;
import java.lang.reflect.Type;
import java.util.Collections;
import java.util.Date;
import java.util.List;


// Reminder has date and text
public class Reminder implements Serializable {
	@SerializedName ("date")
	public final Date date;
	@SerializedName ("reminderText")
	public final String reminderText;
	
	// constructor
	public Reminder (Date date, String reminderText) {
		this.date = date;
		this.reminderText = reminderText;
	}
	
}

