package converter.graphical.buttons;

import converter.graphical.ui.GUI;

import javax.swing.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

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


        if (dialogOption == JFileChooser.APPROVE_OPTION) {
            JOptionPane.showMessageDialog(GUI.getInstance(), "Gespeichert!");
        }
    }
}
