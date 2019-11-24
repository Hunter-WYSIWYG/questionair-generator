import java.io.File;
import java.io.PrintWriter;
import java.nio.file.Files;
import java.nio.file.Paths;

import org.json.JSONArray;
import org.json.JSONObject;

public class Parser {
	private String sourceFile;
	private String targetFile;
	
	public Parser(String source, String target) {
		this.sourceFile = source;
		this.targetFile = target;
	}
	
	public void parsing() {
		
		File file = new File(sourceFile);
		try {
			String content = new String(Files.readAllBytes(Paths.get(file.toURI())), "UTF-8");
			JSONObject questionnaire = new JSONObject(content);

			//JSON lesen Beispiele
			System.out.println(questionnaire.getInt("id"));
			JSONArray elements = questionnaire.getJSONArray("elements");
			JSONObject question_1 = elements.getJSONObject(0);
			System.out.println(question_1.getString("text"));
			
			//CSV schreiben Beispiel
			PrintWriter pw = new PrintWriter(new File(targetFile));
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
