package converter;

import converter.graphical.buttons.JsonBtnEvent;
import java.io.File;
import java.nio.file.Files;
import java.nio.file.Paths;

import org.json.JSONArray;
import org.json.JSONObject;

public class Parser {
	
	private static StringBuilder sb;
	
	public static void parse() {
		
		File file = JsonBtnEvent.getFile();
		try {
			String content = new String(Files.readAllBytes(Paths.get(file.toURI())), "UTF-8");
			
			JSONArray questionnaire = new JSONArray(content);	//JSON Objekte
			JSONObject currentQuestion;
			JSONArray currentAnswers;
			JSONObject currentAnswer;
			int noteCounter = 0;	//Notizanzahl wird von question_id abgezogen um Fragenummer zu erhalten
			sb = new StringBuilder();
			
			if (questionnaire.length()<=0) {	//leere Fragenliste
				sb.append("Die Liste von Fragen und Antworten ist Leer.");
			} else {
			
				currentQuestion = questionnaire.getJSONObject(0);
				
				sb.append("Fragebogen;;");	//Titel des Fragebogens
				sb.append(currentQuestion.getString("title_of_questionnaire"));
				sb.append("\r\n");
				sb.append("\r\n");
				
				for (int i=0;i<questionnaire.length();i++) {	//alle Fragen nacheinander auslesen
					currentQuestion = questionnaire.getJSONObject(i);
					currentAnswers = currentQuestion.getJSONArray("answers");
					
					if (currentQuestion.getString("type_of_question").equals("note")) { //Notiz? else Frage
						noteCounter++;
						sb.append("Notiz;;");	//Notiz schreiben
						sb.append(currentQuestion.getString("question_text"));
						sb.append("\r\n");
						sb.append("\r\n");
					} else {					//Frage + Antworten  + Antwortzeit schreiben
						sb.append("Frage "+(currentQuestion.getInt("question_id")-noteCounter) + ";;");		//Notizanzahl wird von question_id abgezogen um Fragenummer zu erhalten
						sb.append(currentQuestion.getString("question_text"));
						sb.append("\r\n");
						
						for (int j=0; j<currentAnswers.length();j++) {
							currentAnswer = currentAnswers.getJSONObject(j);
							sb.append("Antwort "+currentAnswer.getInt("id") + ";;");
							if (currentQuestion.getString("type_of_question").equals("slider")) {
								sb.append(currentAnswer.getInt("id"));
							} else {
								sb.append(currentAnswer.getString("text"));
							}
							sb.append("\r\n");
						}
						sb.append("Antwortzeit;;");
						sb.append(currentQuestion.getString("answerTime"));
						sb.append("\r\n");
						sb.append("\r\n");
					}
					
				}
				sb.delete(sb.length()-4, sb.length());	//Zeilenumsprung nach letztem Eintrag löschen, ergab Fehler
				
			}
				
		} catch(Exception e1) {
			
		}
	}
	
	public static StringBuilder getStringBuilder() {
		return sb;
	}
	
}
