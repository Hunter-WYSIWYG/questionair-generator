package converter.graphical.table;

import javax.swing.table.DefaultTableModel;

/**
 * Initiates the table with some example data.
 *
 * @author Maximilian Goldacker
 */

public class CsvTableModel extends DefaultTableModel {

    private final int ROWS = 30;
    private final int COLS = 3;

    private Object[] rowData = new Object[COLS];

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

        for (int i = 0; i < COLS; i++) {
            this.addColumn(Integer.toString(i));
        }

        for (int j = 0; j < ROWS; j++) {
            for (int i = 0; i < COLS; i++) {
                rowData[i] = j + " | " + i;
            }
            this.addRow(rowData);
        }
    }

}
