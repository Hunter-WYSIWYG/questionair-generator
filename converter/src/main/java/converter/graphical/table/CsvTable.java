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
}
