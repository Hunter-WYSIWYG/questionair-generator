package converter.graphical.events;

import converter.graphical.table.CsvTableModel;
import converter.graphical.ui.GUI;

import javax.swing.*;
import javax.swing.filechooser.FileNameExtensionFilter;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.nio.Buffer;

/**
 * Handles the event when the button for saving the CSV-file is pressed.
 *
 * @author Maximilian Goldacker
 */
public class SaveBtnEvent implements ActionListener {

    /**
     * Opens a file browser if the user presses the button to save the CSV-file.
     *
     * @param e the event when the button for saving the CSV-file is pressed
     */
    public void actionPerformed(ActionEvent e) {
        JFileChooser saveChooser = new JFileChooser();
        int dialogOption = saveChooser.showSaveDialog(null);
        String message;

        if (dialogOption == JFileChooser.APPROVE_OPTION) {
            File file = saveChooser.getSelectedFile();
            String path = file.getAbsolutePath();

            if (!file.getName().endsWith(".csv")) {
                path += ".csv";
            }

            try {
                BufferedWriter writer = new BufferedWriter(new FileWriter(path));
                writer.write(CsvTableModel.getInstance().getData());
                writer.close();
                message = "Datei gespeichert unter: " + path;
            } catch (IOException exc) {
                exc.printStackTrace();
                message = "Datei konnte nicht gespeichert werden.";
            }

            JOptionPane.showMessageDialog(GUI.getInstance(), message);
        }
    }
}
