package converter.graphical.table;

import javax.swing.table.DefaultTableModel;
import java.util.ArrayList;
import java.util.List;

/**
 * Initiates the table with some example data.
 *
 * @author Maximilian Goldacker, Marcus Gagelmann
 */
public class CsvTableModel extends DefaultTableModel {

    private String data = "";
    private final int COLS = 2;

    private Object[] rowData = new Object[COLS];

    private static CsvTableModel instance;

    /**
     * Initiates a table with data and column headers.
     */
    private CsvTableModel() {
        super();
        initColumns();
    }

    /**
     * Prepares the columns for the table.
     */
    private void initColumns() {

        for (int i = 0; i < COLS; i++) {
            this.addColumn(Integer.toString(i));
        }

    }

    /**
     * @return the instance of the table model
     */
    public static CsvTableModel getInstance() {
        if (instance == null) {
            instance = new CsvTableModel();
        }

        return instance;
    }

    /**
     * Loads the given CSV in the table model.
     *
     * @param data the parsed CSV
     */
    public void changeTable(String data) {
        this.setRowCount(0);

        this.data = data.replaceAll("\r\n", ";");
        String[] values = data.split(";");

        int pos = 0;

        while(pos < values.length) {

            if (values[pos].equals("")) {
                rowData[0] = "";
                rowData[1] = "";
                pos++;
            } else {
                rowData[0] = values[pos];
                rowData[1] = values[pos + 1];
                pos += 2;
            }

            addRow(rowData);
        }

    }

    public String getData() {
        return data;
    }

}
