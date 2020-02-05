package converter.graphical.events;

import converter.adb.ADB;
import converter.graphical.ui.Layout;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

/**
 * Handles the event when the button for installing the android app is pressed.
 *
 * @author Maximilian Goldacker
 */
public class InstallBtnClick implements ActionListener {

    /**
     * Calls ADB to install the smartphone app.
     *
     * @param e the event when the button for installing the android app is pressed
     */
    public void actionPerformed(ActionEvent e) {
        ADB.installAPK();
    }
}

