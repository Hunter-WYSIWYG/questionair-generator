package converter.graphical.buttons;

import converter.graphical.ui.GUI;

import javax.swing.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

public class SaveBtnEvent implements ActionListener {
    public void actionPerformed(ActionEvent e) {
        JFileChooser saveChooser = new JFileChooser();
        int returnValue = saveChooser.showSaveDialog(null);


        if (returnValue == JFileChooser.APPROVE_OPTION) {
            JOptionPane.showMessageDialog(GUI.getInstance(), "Gespeichert!");
        }
    }
}
