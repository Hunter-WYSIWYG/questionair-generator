package converter.UI;

import converter.UI.buttons.JsonBtnEvent;
import converter.UI.table.CsvTable;

import javax.swing.*;
import java.awt.*;

import static java.awt.GridBagConstraints.FIRST_LINE_START;
import static java.awt.GridBagConstraints.PAGE_START;

public class Layout extends JPanel {
    public Layout() {
        super(new GridBagLayout());

        GridBagConstraints constraints = new GridBagConstraints();

        JButton jsonButton = new JButton("JSON auswählen");
        //jsonButton.setBounds(20,20,135,25);
        constraints.gridx = 0;
        constraints.gridy = 0;
        constraints.insets = new Insets(10,10,0,10);
        //constraints.anchor = PAGE_START;
        add(jsonButton, constraints);
        jsonButton.addActionListener(new JsonBtnEvent());

        JButton convertButton = new JButton("Konvertieren");
        //convertButton.setBounds(20,55,135,25);
        constraints.gridx = 2;
        constraints.gridy = 0;
        add(convertButton, constraints);

        JTable table = new CsvTable();
        JScrollPane scrollPane = new JScrollPane(table);
        scrollPane.setPreferredSize(new Dimension(360,200));
        constraints.gridx = 0;
        constraints.gridy = 1;
        constraints.gridwidth = 3;
        //constraints.weightx = 1.0;
        constraints.weighty = 1.0;
        add(scrollPane, constraints);
    }
}
