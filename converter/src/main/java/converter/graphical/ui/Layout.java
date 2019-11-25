package converter.graphical.ui;

import converter.graphical.buttons.JsonBtnEvent;
import converter.graphical.table.CsvTable;

import javax.swing.*;
import java.awt.*;

public class Layout extends JPanel {

    private static JLabel fileLabel;
    private static Layout instance;

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

        JButton convertButton = new JButton("Konvertieren");
        constraints.gridx = 0;
        constraints.gridy = 1;
        add(convertButton, constraints);

        JTable table = new CsvTable();
        JScrollPane scrollPane = new JScrollPane(table);
        scrollPane.setPreferredSize(new Dimension(360,200));
        constraints.gridx = 0;
        constraints.gridy = 2;
        constraints.gridwidth = 3;
        constraints.weighty = 1.0;
        add(scrollPane, constraints);
    }

    static Layout getInstance() {
        if (instance == null) {
            instance = new Layout();
        }

        return instance;
    }

    public static void changeFileLabel(String text) {
        fileLabel.setText(text);
    }
}
