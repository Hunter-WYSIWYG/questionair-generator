package converter.graphical.table;

import javax.swing.table.DefaultTableModel;

/**
 * This class initiates the table with some example data.
 */

public class CsvTableModel extends DefaultTableModel {

    private int rows = 30, cols = 3;

    private Object[] rowData = new Object[cols];

    /**
     * Initiates a table with data and column headers.
     */
    public CsvTableModel() {
        super();
        initModelData();
    }

    /**
     * Writes some example data in the table.
     */
    private void initModelData() {

        for (int i = 0; i < cols; i++) {
            this.addColumn(Integer.toString(i));
        }

        for (int j = 0; j < rows; j++) {
            for (int i = 0; i < cols; i++) {
                rowData[i] = "";
            }
            this.addRow(rowData);
        }
    }
}
