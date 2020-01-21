package converter.graphical.ui;

import converter.graphical.buttons.JsonBtnEvent;
import converter.graphical.buttons.SaveBtnEvent;
import converter.graphical.table.CsvTable;
import javax.swing.*;
import java.awt.*;
import java.io.File;

import static java.awt.GridBagConstraints.FIRST_LINE_START;

/**
 * Represents the layout of the GUI.
 *
 * @author Maximilian Goldacker
 */
public class Layout extends JPanel {

    private static JLabel fileLabel;
    private static Layout instance;

    /**
     * Initiates the layout of the GUI with all elements
     */
    private Layout() {
        super(new GridBagLayout());
        
        GridBagConstraints constraints = new GridBagConstraints();

        JButton jsonButton = new JButton("JSON auswählen");
        constraints.gridx = 0;
        constraints.gridy = 0;
        constraints.insets = new Insets(10,10,0,10);
        add(jsonButton, constraints);
        jsonButton.addActionListener(new JsonBtnEvent());

        fileLabel = new JLabel("Keine Datei ausgewählt...");
        constraints.gridx = 1;
        constraints.gridy = 0;
        add(fileLabel, constraints);

        JTable table = new CsvTable();
        table.setTableHeader(null);
        JScrollPane scrollPane = new JScrollPane(table);
        scrollPane.setPreferredSize(new Dimension(360,19));
        constraints.gridx = 0;
        constraints.gridy = 2;
        constraints.gridwidth = 3;
        constraints.weighty = 1.0;
        add(scrollPane, constraints);

        JButton saveButton = new JButton("Speichern");
        constraints.gridx = 0;
        constraints.gridy = 3;
        constraints.weighty = 0;
        constraints.anchor = FIRST_LINE_START;
        constraints.insets = new Insets(10, 10, 10, 0);
        saveButton.addActionListener(new SaveBtnEvent());
        add(saveButton, constraints);
    }

    /**
     * @return the layout of the GUI
     */
    public static Layout getInstance() {
        if (instance == null) {
            instance = new Layout();
        }

        return instance;
    }

    /**
     * Changes the label of the current selected file.
     *
     * @param text the text to be set for the label
     */
    public void changeFileLabel(String text) {
        fileLabel.setText(text);
    }

}
