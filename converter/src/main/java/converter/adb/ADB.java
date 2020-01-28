package converter.adb;

import javax.swing.*;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;

public class ADB {

    private ADB() {}

    /**
     * @return the list of json-files/answered questionnaires
     */
    public static Object[] listJsonFiles() {
        ArrayList<String> jsonFiles = new ArrayList();

        try {
            Process process = Runtime.getRuntime().exec("adb shell ls /sdcard/Android/data/com.example.app/files/antworten");
            BufferedReader stdInput = new BufferedReader(new InputStreamReader(process.getInputStream()));

            String line = null;
            while ((line = stdInput.readLine()) != null) {
                jsonFiles.add(line);
            }

        } catch (IOException exc) {
            String message = "Es gab einen Fehler mit der adb Konsole. Überprüfen Sie die Installation.";
            JOptionPane.showMessageDialog(null, message,"Fehler", JOptionPane.CANCEL_OPTION);
            System.err.println(exc);
        }

        return jsonFiles.toArray();
    }

    /**
     * Downloads the file under the given path from the connected Android device.
     *
     * @param path the file to be downloaded
     */
    public static void pullFile(String path) {
        try {
            Process process = Runtime.getRuntime().exec("adb pull " + path + " ./");
            process.waitFor();
        } catch (IOException exc) {
            String message = "Es gab einen Fehler mit der adb Konsole. Überprüfen Sie die Installation.";
            JOptionPane.showMessageDialog(null, message,"Fehler", JOptionPane.CANCEL_OPTION);
            System.err.println(exc);
        } catch (InterruptedException exc) {
            String message = "Die Fragebögen konnten nicht abgerufen werden, weil ein wichtiger Prozess unterbrochen wurde";
            JOptionPane.showMessageDialog(null, message,"Fehler", JOptionPane.CANCEL_OPTION);
            System.err.println(exc);
        }
    }
}
