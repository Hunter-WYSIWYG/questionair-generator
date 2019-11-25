package converter.graphical.ui;


import javax.swing.*;
import java.awt.event.ActionEvent;
import java.awt.event.KeyEvent;

public class GUI extends JFrame {

    private static GUI instance;

    private GUI() {

        setTitle("Converter");
        setSize(400,300);
        setLocationRelativeTo(null);
        setContentPane(Layout.getInstance());
        setVisible(true);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

        initMenu();
    }

    public static GUI getInstance() {
        if (instance == null) {
            instance = new GUI();
        }

        return instance;
    }

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