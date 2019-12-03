package converter.graphical.buttons;

import javax.swing.JFileChooser;
import javax.swing.JOptionPane;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.File;
import converter.graphical.ui.GUI;
import converter.graphical.ui.Layout;

/**
 * Class that handles the event when the button for selecting the JSON-file is pressed.
 */

public class JsonBtnEvent implements ActionListener {

    /**
     * Opens a file browser if the user presses the button to select the JSON-file.
     *
     * @param e the event when the button for selecting the JSON-file is pressed
     */
	
	static File json;
	
    public void actionPerformed(ActionEvent e) {
        JFileChooser jsonChooser = new JFileChooser();
        int returnValue = jsonChooser.showOpenDialog(null);

        if (returnValue == JFileChooser.APPROVE_OPTION) {
            File file = jsonChooser.getSelectedFile();
            JOptionPane.showMessageDialog(GUI.getInstance(), "Es wurde folgende Datei ausgewählt: " + file.getName());
            Layout.changeFileLabel(file.getName());
            json = file;
        }
    }
    
    public static File getFile() {
    	return json;
    }
}
