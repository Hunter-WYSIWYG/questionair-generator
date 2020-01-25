package converter.graphical.events;

import converter.adb.ADB;
import converter.graphical.ui.GUI;

import javax.swing.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.File;

/**
 * Handles the event when the menu item for uploading a questionnaire is pressed.
 *
 * @author Maximilian Goldacker
 */
public class FragebogenHochladenClick implements ActionListener {

    /**
     * Opens a file browser if the user presses the menu item for uploading a questionnaire.
     * Calls ADB to upload that file.
     *
     * @param e the event when the menu item for uploading a questionnaire is pressed
     */
    public void actionPerformed(ActionEvent e) {
        JFileChooser fileChooser = new JFileChooser();
        int dialogOption = fileChooser.showOpenDialog(null);

        if (dialogOption == JFileChooser.APPROVE_OPTION) {
            File fragebogen = fileChooser.getSelectedFile();
            ADB.pushFile(fragebogen.toString());
        }
    }
}
