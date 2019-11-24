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
		
		GUI newGUI = new GUI("gui", args[0], args[1]);

	}

}
