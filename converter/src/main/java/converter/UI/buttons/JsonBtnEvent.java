package converter.UI.buttons;

import javax.swing.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

public class JsonBtnEvent implements ActionListener {
    public void actionPerformed(ActionEvent e) {
        JFileChooser jsonChooser = new JFileChooser();
        jsonChooser.showOpenDialog(null);
    }
}
