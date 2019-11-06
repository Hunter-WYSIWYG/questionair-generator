package com.example.app.question;

import com.google.gson.*;
import org.json.JSONException;

import java.lang.reflect.Type;

class ReminderAdapter implements JsonSerializer<Reminder>, JsonDeserializer<Reminder> {
	// convert from JSON to Question
	@Override
	public JsonElement serialize (Reminder reminder, Type typeOfReminder, JsonSerializationContext context) {
		return context.serialize (reminder);
	}
	
	// convert from Question to JSON
	@Override
	public Reminder deserialize (JsonElement json, Type typeOfT, JsonDeserializationContext context) throws JsonParseException {
		JsonObject questionJson = json.getAsJsonObject ();
		try {
			return context.deserialize (json, Reminder.class);
			
		} catch (JsonParseException error) {
			throw error;
		}
	}
}
