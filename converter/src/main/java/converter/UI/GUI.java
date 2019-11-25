package converter.UI;

import javax.swing.*;

public class GUI extends JFrame {

    public GUI() {

        setTitle("Converter");
        setSize(400,300);
        setLocationRelativeTo(null);
        setContentPane(new Layout());
        setVisible(true);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

    }

}