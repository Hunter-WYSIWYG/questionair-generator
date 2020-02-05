package converter.graphical.ui;

import converter.graphical.events.FragebogenHochladenClick;

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
        setSize(400,435);
        setResizable(true);
        setLocationRelativeTo(null);
        initMenu();
        setContentPane(Layout.getInstance());
        setVisible(true);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
    }

    /**
     * Initializes the menu.
     */
    private void initMenu() {
        JMenuBar menuBar = new JMenuBar();
        JMenu menu = new JMenu("Datei");
        JMenuItem fragebogenHochladen = new JMenuItem("Fragebogen hochladen");

        fragebogenHochladen.addActionListener(new FragebogenHochladenClick());

        menu.add(fragebogenHochladen);
        menuBar.add(menu);
        setJMenuBar(menuBar);

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