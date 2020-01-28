package converter.graphical.events;

import converter.graphical.ui.Layout;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

/**
 * Handles the event when the button for refreshing the JSON-files is pressed.
 *
 * @author Maximilian Goldacker
 */
public class RefreshBtnClick implements ActionListener {

    /**
     * Updates the combo box containing the JSON-files.
     *
     * @param e the event when the button for refreshing the JSON-files is pressed
     */
    public void actionPerformed(ActionEvent e) {
        Layout.getInstance().updateJsonComboBox();
    }
}

