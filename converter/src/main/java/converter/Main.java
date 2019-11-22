import java.io.File;
import java.nio.file.Files;
import java.nio.file.Paths;

import org.json.JSONArray;
import org.json.JSONObject;

public class JSON_to_CSV {

	public static void main(String[] args) {
		
		File file = new File(args[0]);
		try {
			String content = new String(Files.readAllBytes(Paths.get(file.toURI())), "UTF-8");
			JSONObject json = new JSONObject(content);

			System.out.println(json.getInt("id"));
			
			JSONArray json2 = json.getJSONArray("elements");
			JSONObject json3 = json2.getJSONObject(0);
			System.out.println(json3.getString("text"));
			
		} catch(Exception e) {
			
		}

	}

}
