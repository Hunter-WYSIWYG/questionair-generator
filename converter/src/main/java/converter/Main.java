import java.io.File;
import java.nio.file.Files;
import java.nio.file.Paths;

import org.json.JSONArray;
import org.json.JSONObject;
import java.io.PrintWriter;

public class Main {
	//Dateipfad mit "\\" zur Ordnertrennung und Name der JSON in args[0] übergeben
	//z.B. C:\\User\\Eclipse\\exampleQuestionnaire.json
	//Dateipfad mit "\\" zur Ordnertrennung und Name der Zieldatei in args[1] übergeben
	//z.B. C:\\User\\Eclipse\\test.csv
	public static void main(String[] args) {
		
		File file = new File(args[0]);
		try {
			String content = new String(Files.readAllBytes(Paths.get(file.toURI())), "UTF-8");
			JSONObject questionnaire = new JSONObject(content);

			//JSON lesen Beispiele
			System.out.println(questionnaire.getInt("id"));
			JSONArray elements = questionnaire.getJSONArray("elements");
			JSONObject question_1 = elements.getJSONObject(0);
			System.out.println(question_1.getString("text"));
			
			//CSV schreiben Beispiel
			PrintWriter pw = new PrintWriter(new File(args[1]));
			StringBuilder sb = new StringBuilder();
			
			sb.append("id;");
			sb.append(questionnaire.getInt("id"));
			sb.append("\r\n");
			sb.append("title;");
			sb.append(questionnaire.getString("title"));
			sb.append("\r\n");
			sb.append("priority;");
			sb.append(questionnaire.getInt("priority"));
			
			pw.write(sb.toString());
			pw.close();
			System.out.println("file created");
			
		} catch(Exception e) {
			
		}

	}

}
