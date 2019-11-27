package converter.graphical.ui;

import javax.swing.*;

/**
 * This class implements the GUI of the converter tool.
 */

public class GUI extends JFrame {

    /**
     * the instance of the GUI
     */
    private static GUI instance;

    /**
     * Initiates the GUI.
     */
    private GUI() {

        setTitle("Converter");
        setSize(400,400);
        setResizable(false);
        setLocationRelativeTo(null);
        setContentPane(Layout.getInstance());
        setVisible(true);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

        initMenu();
    }

    /**
     * Returns the instance of the GUI.
     *
     * @return the instance of the GUI
     */
    public static GUI getInstance() {
        if (instance == null) {
            instance = new GUI();
        }

        return instance;
    }

    /**
     * Initiates the menu for selecting devices.
     */
    private void initMenu() {
        JMenuBar menuBar = new JMenuBar();
        JMenu menu = new JMenu("Gerät");
        JMenu chooseDevice = new JMenu("Gerät auswählen");
        JMenuItem uploadAPK = new JMenuItem("APK hochladen");

        menu.add(chooseDevice);
        menu.add(uploadAPK);
        menuBar.add(menu);

        setJMenuBar(menuBar);
    }
}