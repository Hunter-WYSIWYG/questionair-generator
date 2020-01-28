package converter.graphical.events;

import converter.adb.ADB;
import converter.graphical.table.CsvTableModel;
import converter.graphical.ui.Layout;
import converter.parser.Parser;

import javax.swing.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.File;
import java.io.IOException;

/**
 * Handles the event when the selection inside the combobox changes.
 *
 * @author Maximilian Goldacker
 */
public class ComboBoxChanged implements ActionListener {

    /**
     * Downloads the selected JSON-file and calls the parser.
     *
     * @param e the event when the selection inside the combobox changes
     */
    public void actionPerformed(ActionEvent e) {

        if (Layout.isNotInstantiated()) {
            return;
        }

        String selectedJsonFile = Layout.getInstance().getSelectedJsonFile();

        if (selectedJsonFile == null || selectedJsonFile.equals("Beantworteten Bogen auswählen")) {
            return;
        }

        Layout.getInstance().updateJsonComboBox();

        String path = "/sdcard/Android/data/com.example.app/files/antworten/" + selectedJsonFile;

        ADB.pullFile(path);
        File downloadedJson = new File(System.getProperty("user.dir") + "\\" + selectedJsonFile);
        String csv = Parser.parse(downloadedJson);
        CsvTableModel.getInstance().changeTable(csv);
    }
}

