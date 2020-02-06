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

    /**
     * Uploads the file under the given path to the connected Android device.
     *
     * @param path the file to be uploaded
     */
    public static void pushFile(String path) {
        try {
            Process process = Runtime.getRuntime().exec("adb push " + path + " sdcard/Android/data/com.example.app/files/fragebogen/");
            process.waitFor();

            BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
            if (reader.readLine().equals("adb: error: failed to get feature set: no devices/emulators found")) {
                String message = "Es wurde kein angeschlossenes Gerät gefunden!";
                JOptionPane.showMessageDialog(null, message,"Fehler", JOptionPane.CANCEL_OPTION);
                return;
            }

            String message = "Fragebogen erfolgreich hochgeladen.";
            JOptionPane.showMessageDialog(null, message,"Upload erfolgreich", JOptionPane.INFORMATION_MESSAGE);
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

    /**
     * Installs the APK on a connected smartphone.
     */
    public static void installAPK() {
        try {
            Process process = Runtime.getRuntime().exec("adb install ../android-app/app.apk");
            process.waitFor();

            BufferedReader reader = new BufferedReader(new InputStreamReader(process.getErrorStream()));

            String line;
            while ((line = reader.readLine()) != null) {
                if (line.equals("error: no devices/emulators found")
                    || line.equals("adb: failed to stat app.apk: No such file or directory")) {
                    String message = "Gerät oder app.apk nicht gefunden.";
                    JOptionPane.showMessageDialog(null, message, "Fehler", JOptionPane.CANCEL_OPTION);
                    return;
                }
            }

            String message = "App erfolgreich installiert.";
            JOptionPane.showMessageDialog(null, message,"Upload erfolgreich", JOptionPane.INFORMATION_MESSAGE);
        } catch (InterruptedException exc) {
            String message = "Die Fragebögen konnten nicht abgerufen werden, weil ein wichtiger Prozess unterbrochen wurde.";
            JOptionPane.showMessageDialog(null, message,"Fehler", JOptionPane.CANCEL_OPTION);
            System.err.println(exc);
        } catch (IOException exc) {
            String message = "Die Fragebögen konnten nicht abgerufen werden, weil es zu einem I/O-Fehler kam";
            JOptionPane.showMessageDialog(null, message,"Fehler", JOptionPane.CANCEL_OPTION);
            System.err.println(exc);
        }
    }
}
