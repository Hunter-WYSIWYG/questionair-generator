package converter.parser;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.Paths;

import org.json.JSONArray;
import org.json.JSONObject;

/**
 * Contains the parse-function of the converter tool.
 *
 * @author Marcus Gagelmann
 */
public class Parser {

    /**
     * Gets a file from the JsonBtnEvent and creates string containing the data of the file as CSV.
     *
     * @return the parsed JSON-file as CSV format
     */
    public static String parse(File file) {

        try {
            String content = new String(Files.readAllBytes(Paths.get(file.toURI())), "UTF-8");

            JSONArray questionnaire = new JSONArray(content);
            JSONObject currentQuestion;
            JSONArray currentAnswers;
            JSONObject currentAnswer;
            //Notizanzahl wird von question_id abgezogen um Fragenummer zu erhalten
            int noteCounter = 0;
            StringBuilder sb = new StringBuilder();

            if (questionnaire.length()<=0) {
                //leere Fragenliste
                sb.append("Die Liste von Fragen und Antworten ist Leer.");
            } else {

                currentQuestion = questionnaire.getJSONObject(0);
                
		for (int i=0;i<questionnaire.length();i++) {
                    //alle Fragen nacheinander auslesen
                    currentQuestion = questionnaire.getJSONObject(i);
                    currentAnswers = currentQuestion.getJSONArray("answers");

                    sb.append(currentQuestion.getString("title_of_questionnaire") + ";");
                    sb.append(currentQuestion.getString("userid") + ";");
                    sb.append(currentQuestion.getString("answerTime") + ";");
                    sb.append(currentQuestion.getInt("question_id") + ";");
                    sb.append(currentQuestion.getString("question_text") + ";");
                    
                    for (int j=0; j<currentAnswers.length();j++) {
                    	//alle Antworten nacheinander auslesen
                        currentAnswer = currentAnswers.getJSONObject(j);
                        if (currentQuestion.getString("type_of_question").equals("slider")) {
                        	sb.append(currentAnswer.getInt("id"));
                        } else {
                        	sb.append(currentAnswer.getString("text") + ";");
                        }
                    }
                }
            }
            
            return sb.toString();

        } catch(Exception e1) {
            e1.printStackTrace();
            return null;
        }
    }

}
