package converter.graphical.buttons;

import javax.swing.JFileChooser;
import javax.swing.JOptionPane;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.File;
import converter.graphical.ui.GUI;
import converter.graphical.ui.Layout;

public class JsonBtnEvent implements ActionListener {
    public void actionPerformed(ActionEvent e) {
        JFileChooser jsonChooser = new JFileChooser();
        int returnValue = jsonChooser.showOpenDialog(null);

        if (returnValue == JFileChooser.APPROVE_OPTION) {
            File file = jsonChooser.getSelectedFile();
            JOptionPane.showMessageDialog(GUI.getInstance(), "Es wurde folgende Datei ausgewählt: " + file.getName());
            Layout.changeFileLabel(file.getName());
        }
    }
}
