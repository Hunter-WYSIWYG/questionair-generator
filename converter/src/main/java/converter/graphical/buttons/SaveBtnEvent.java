package converter.graphical.buttons;

import converter.Parser;
import converter.graphical.ui.GUI;

import javax.swing.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.File;
import java.io.FileWriter;

public class SaveBtnEvent implements ActionListener {
    public void actionPerformed(ActionEvent e) {
        JFileChooser saveChooser = new JFileChooser();
        int returnValue = saveChooser.showSaveDialog(null);

        if (returnValue == JFileChooser.APPROVE_OPTION) {
        	try {
	            File targetFile = saveChooser.getSelectedFile();
	            FileWriter fw = new FileWriter(targetFile);
	            fw.write(Parser.getStringBuilder().toString());
	            fw.close();
				System.out.println("file created");
        	} catch(Exception e2) {
        		
        	}
            JOptionPane.showMessageDialog(GUI.getInstance(), "Gespeichert!");
        }
    }
}
