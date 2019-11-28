package com.example.app.question;

import android.support.annotation.NonNull;

import com.google.gson.JsonDeserializationContext;
import com.google.gson.JsonDeserializer;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParseException;
import com.google.gson.JsonSerializationContext;
import com.google.gson.JsonSerializer;

import java.lang.reflect.Type;

class QuestionAdapter implements JsonSerializer<Question>, JsonDeserializer<Question> {
	// convert from JSON to Question
	@Override
	public JsonElement serialize(Question question, Type typeOfQuestion, @NonNull JsonSerializationContext context) {
		return context.serialize(question);
	}
	
	// convert from Question to JSON
	@Override
	public Question deserialize(@NonNull JsonElement json, Type typeOfT, @NonNull JsonDeserializationContext context) throws JsonParseException {
		JsonObject questionJson = json.getAsJsonObject();
		QuestionType type = context.deserialize(questionJson.get("type"), QuestionType.class);
		if (type == QuestionType.SingleChoice)
			return context.deserialize(json, ChoiceQuestion.class);
		else if (type == QuestionType.MultipleChoice)
			return context.deserialize(json, ChoiceQuestion.class);
		else if (type == QuestionType.Slider)
			return context.deserialize(json, SliderQuestion.class);
		else if (type == QuestionType.PercentSlider)
			return context.deserialize(json, PercentSliderQuestion.class);
		else if (type == QuestionType.Note)
			return context.deserialize(json, Note.class);
		else if (type == QuestionType.Table)
			return context.deserialize(json, TableQuestion.class);
		else if (type == QuestionType.SliderButton)
			return context.deserialize(json, SliderButtonQuestion.class);
		else
			throw new JsonParseException("unknown question type: " + type);
	}
}
