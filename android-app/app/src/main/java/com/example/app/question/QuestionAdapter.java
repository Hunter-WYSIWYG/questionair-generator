package com.example.app.question;

import com.google.gson.*;

import java.lang.reflect.Type;

class QuestionAdapter implements JsonSerializer<Question>, JsonDeserializer<Question> {
	// convert from JSON to Question
	@Override
	public JsonElement serialize (Question question, Type typeOfQuestion, JsonSerializationContext context) {
		return context.serialize (question);
	}
	
	// convert from Question to JSON
	@Override
	public Question deserialize (JsonElement json, Type typeOfT, JsonDeserializationContext context) throws JsonParseException {
		JsonObject questionJson = json.getAsJsonObject ();
		
		boolean isNote = context.deserialize (questionJson.get ("_type"), String.class).equals ("Note");
		if (isNote)
			return context.deserialize (json, Note.class);
		
		QuestionType type = context.deserialize (questionJson.get ("questionType"), QuestionType.class);
		if (type == QuestionType.SingleChoice)
			return context.deserialize (json, ChoiceQuestion.class);
		else if (type == QuestionType.MultipleChoice)
			return context.deserialize (json, ChoiceQuestion.class);
		else if (type == QuestionType.BinaryChoice)
			return context.deserialize (json, ChoiceQuestion.class);
		else if (type == QuestionType.BipolarSlider)
			return context.deserialize (json, SliderQuestion.class);
		else if (type == QuestionType.UnipolarSlider)
			return context.deserialize (json, SliderQuestion.class);
		else if (type == QuestionType.PercentSlider)
			return context.deserialize (json, PercentSliderQuestion.class);
		else if (type == QuestionType.Note)
			return context.deserialize (json, Note.class);
		else if (type == QuestionType.Table)
			return context.deserialize (json, TableQuestion.class);
		else if (type == QuestionType.SliderButton)
			return context.deserialize (json, SliderButtonQuestion.class);
		else
			throw new JsonParseException ("unknown question type: " + type);
	}
}