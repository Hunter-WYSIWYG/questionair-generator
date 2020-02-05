package converter.graphical.ui;

import converter.adb.ADB;
import converter.graphical.events.*;
import converter.graphical.table.CsvTable;

import javax.swing.*;
import java.awt.*;

import static java.awt.GridBagConstraints.*;

/**
 * Represents the layout of the GUI.
 *
 * @author Maximilian Goldacker
 */
public class Layout extends JPanel {

    private static boolean alreadyInstantiated;
    private static Layout instance;
    private static JComboBox jsonComboBox;

    /**
     * Initiates the layout of the GUI with all elements
     */
    private Layout() {
        super(new GridBagLayout());

        GridBagConstraints constraints = new GridBagConstraints();

        jsonComboBox = new JComboBox();
        jsonComboBox.addActionListener(new ComboBoxChanged());
        updateJsonComboBox();
        constraints.gridx = 0;
        constraints.gridy = 0;
        constraints.gridwidth = 3;
        constraints.insets = new Insets(10,10,0,10);
        add(jsonComboBox, constraints);

        JButton refresh = new JButton("Aktualisieren");
        refresh.addActionListener(new RefreshBtnClick());
        constraints.gridx = 0;
        constraints.gridy = 1;
        add(refresh, constraints);

        JTable table = new CsvTable();
        JScrollPane scrollPane = new JScrollPane(table);
        scrollPane.setPreferredSize(new Dimension(360,200));
        constraints.gridx = 0;
        constraints.gridy = 2;
        constraints.weighty = 1.0;
        add(scrollPane, constraints);

        JButton saveButton = new JButton("Speichern");
        constraints.gridx = 0;
        constraints.gridy = 3;
        constraints.anchor = FIRST_LINE_START;
        constraints.gridwidth = 1;
        constraints.weighty = 0;
        constraints.insets = new Insets(10, 10, 10, 0);
        saveButton.addActionListener(new SaveBtnEvent());
        add(saveButton, constraints);

        JButton upload = new JButton("Bogen hochladen");
        upload.addActionListener(new FragebogenHochladenClick());
        constraints.gridx = 0;
        constraints.gridy = 4;
        constraints.anchor = FIRST_LINE_START;
        constraints.weightx = 0.5;
        constraints.insets = new Insets(0, 10, 10, 10);
        add(upload, constraints);

        JButton install = new JButton("App installieren");
        install.addActionListener(new InstallBtnClick());
        constraints.gridx = 1;
        constraints.gridy = 4;
        constraints.anchor = FIRST_LINE_END;
        constraints.weightx = 0.5;
        constraints.insets = new Insets(0, 0, 10, 10);
        add(install, constraints);

    }

    public static boolean isNotInstantiated() {
        return (instance == null);
    }

    /**
     * Updates the combobox with the JSON-files.
     */
    public void updateJsonComboBox() {
        jsonComboBox.removeAllItems();

        jsonComboBox.addItem("Beantworteten Bogen auswählen");

        for (Object s : ADB.listJsonFiles()) {
            jsonComboBox.addItem(s);
        }
    }

    public String getSelectedJsonFile() {
        return (String)jsonComboBox.getSelectedItem();
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

}
