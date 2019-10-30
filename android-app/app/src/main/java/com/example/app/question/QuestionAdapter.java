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
		QuestionType type = context.deserialize (questionJson.get (Question.TYPE_JSON_NAME), QuestionType.class);
		if (type == QuestionType.SingleChoice)
			return context.deserialize (json, ChoiceQuestion.class);
		else if (type == QuestionType.MultipleChoice)
			return context.deserialize (json, ChoiceQuestion.class);
		else if (type == QuestionType.Slider)
			return context.deserialize (json, SliderQuestion.class);
		else if (type == QuestionType.Note)
			return context.deserialize (json, Note.class);
		else
			throw new JsonParseException ("unknown question type: " + type);
	}
}
