package converter.graphical.ui;

import javax.swing.*;

/**
 * Implements the GUI of the converter tool.
 *
 * @author Maximilian Goldacker
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
        //setJMenuBar(Menu.getMenuBar());
        setContentPane(Layout.getInstance());
        setVisible(true);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
    }

    /**
     * @return the instance of the GUI
     */
    public static GUI getInstance() {
        if (instance == null) {
            instance = new GUI();
        }

        return instance;
    }



}