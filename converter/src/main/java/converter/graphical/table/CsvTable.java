package converter.graphical.table;

import javax.swing.*;
import javax.swing.table.TableColumn;

/**
 * This class is the implementation for the representation of a CSV-file as a table.
 */

public class CsvTable extends JTable {

    /**
     * Initiates the table for the CSV preview.
     */
    public CsvTable() {
        super(new CsvTableModel());
        setColumnWidth();
    }

    /**
     * Sets the width for each column.
     */
    private void setColumnWidth() {
        for (int i = 0; i < this.getColumnCount(); i++) {
            TableColumn c = this.getColumnModel().getColumn(i);
            c.setPreferredWidth(5);
        }
    }
    
    public void changeTable(String data) {	//CSV Stringbuilder data as String
    	String[] values = new String[this.getRowCount()*this.getColumnCount()];
    	String[] val = data.split(";");
    	String[] zeilenumbruch;
    	
    	for(int i=0; i<values.length; i++) {
    		if(i<val.length) {
    			values[i]=val[i];
    		} else {
    			values[i]="";
    		}
    	}
    	
    	int currentValue = 0;
    	
    	for(int row=0; row<this.getRowCount(); row++) {
    		for(int col=0; col<this.getColumnCount(); col++) {
    			
    			if(values[currentValue].contains("\r\n")) {
    				zeilenumbruch = values[currentValue].split("\r\n");
    				for(int i=0;i<zeilenumbruch.length;i++) {
    					if(col==0) {
	    					this.setValueAt(zeilenumbruch[i], row+i, col);	//col==0
	    					this.setValueAt("", row+i, col+1);
	    					this.setValueAt("", row+i, col+2);
    					} else {
	    					this.setValueAt(zeilenumbruch[i], row+i, col);	//col==3
    					}
    					col=0;
    				}
    				row=row+zeilenumbruch.length-1;
    			} else {
    				this.setValueAt(values[currentValue], row, col);
    			}
    			currentValue++;
    		}
    	}
    }
}
