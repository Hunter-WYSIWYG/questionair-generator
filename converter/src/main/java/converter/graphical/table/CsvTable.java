package converter.graphical.table;

import javax.swing.*;
import javax.swing.table.TableColumn;

/**
 * Contains the implementation for the representation of a CSV-file as a table.
 *
 * @author Maximilian Goldacker
 */
public class CsvTable extends JTable {

    /**
     * Initiates the table for the CSV preview.
     */
    public CsvTable() {
        super(CsvTableModel.getInstance());
        setColumnWidth(5);
    }

    /**
     * Sets the width for each column.
     */
    private void setColumnWidth(int width) {
        for (int i = 0; i < this.getColumnCount(); i++) {
            TableColumn c = this.getColumnModel().getColumn(i);
            c.setPreferredWidth(width);
        }
    }
}
