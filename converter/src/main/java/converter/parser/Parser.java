package converter.parser;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.Paths;

import org.json.JSONArray;
import org.json.JSONObject;

import javax.swing.*;

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

                sb.append("Fragebogen;");
                //Titel des Fragebogens
                sb.append(currentQuestion.getString("title_of_questionnaire"));
                sb.append("\r\n");
                sb.append("\r\n");

                for (int i=0;i<questionnaire.length();i++) {
                    //alle Fragen nacheinander auslesen
                    currentQuestion = questionnaire.getJSONObject(i);
                    currentAnswers = currentQuestion.getJSONArray("answers");

                    if (currentQuestion.has("type_of_question") && currentQuestion.getString("type_of_question").equals("note")) { //Notiz? else Frage
                        noteCounter++;
                        //Notiz schreiben
                        sb.append("Notiz;");
                        sb.append(currentQuestion.getString("question_text"));
                        sb.append("\r\n");
                        sb.append("\r\n");
                    } else {
                        //Frage + Antworten  + Antwortzeit schreiben
                        sb.append("Frage "+(currentQuestion.getInt("question_id")-noteCounter) + ";");
                        //Notizanzahl wird von question_id abgezogen um Fragenummer zu erhalten
                        sb.append(currentQuestion.getString("question_text"));
                        sb.append(";");

                        for (int j=0; j<currentAnswers.length();j++) {
                            currentAnswer = currentAnswers.getJSONObject(j);
                            sb.append("Antwort "+currentAnswer.getInt("id") + ";");
                            if (currentQuestion.has("type_of_question") && currentQuestion.getString("type_of_question").equals("slider")) {
                                sb.append(currentAnswer.getInt("id"));
                            } else {
                                sb.append(currentAnswer.getString("text"));
                            }
                            sb.append(";");
                        }
                        sb.append("Antwortzeit;");
                        sb.append(currentQuestion.getString("answerTime"));
                        sb.append("\r\n");
                        sb.append("\r\n");
                    }

                }
                //Zeilenumsprung nach letztem Eintrag löschen, ergab Fehler
                sb.delete(sb.length()-4, sb.length());

            }

            return sb.toString();

        } catch(Exception exc) {
            String message = "Der Fragebogen konnte nicht gefunden werden. Wurde die Verbindung zum Handy unterbrochen?";
            JOptionPane.showMessageDialog(null, message,"Fehler", JOptionPane.CANCEL_OPTION);
            System.err.println(exc);
            return "";
        }
    }

}
