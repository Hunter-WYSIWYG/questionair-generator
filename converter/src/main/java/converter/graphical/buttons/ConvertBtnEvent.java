package converter.graphical.buttons;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.File;

import javax.swing.JFileChooser;
import javax.swing.JOptionPane;

import converter.Parser;
import converter.graphical.table.CsvTableModel;
import converter.graphical.ui.GUI;
import converter.graphical.ui.Layout;

public class ConvertBtnEvent implements ActionListener {

    public void actionPerformed(ActionEvent e) {
        
    	try {
	    	if (JsonBtnEvent.getFile().exists()) {
	    		
		    	Parser.parse();
		    	Layout.changeTable();
		    	
	    	}
    	} catch (Exception e3) {
    		
    	}
    }
	
}
