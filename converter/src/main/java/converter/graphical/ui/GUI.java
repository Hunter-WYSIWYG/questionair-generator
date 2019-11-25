package converter.graphical.ui;


import javax.swing.JFrame;

public class GUI extends JFrame {

    private static GUI instance;

    private GUI() {
        setTitle("Converter");
        setSize(400,300);
        setLocationRelativeTo(null);
        setContentPane(Layout.getInstance());
        setVisible(true);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
    }

    public static GUI getInstance() {
        if (instance == null) {
            instance = new GUI();
        }

        return instance;
    }
}