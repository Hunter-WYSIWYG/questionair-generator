package converter;

import converter.devices.Devices;
import converter.graphical.ui.GUI;

/**
 * Contains the main-function of the converter tool.
 *
 * @author Maximilian Goldacker
 */
public class Main {

    /**
     * The main function of the converter tool starts the GUI.
     *
     * @param args the arguments given for the converter tool, no arguments needed
     */
    public static void main(String[] args) {
        GUI.getInstance();
        Devices.getDevices();
    }
}
