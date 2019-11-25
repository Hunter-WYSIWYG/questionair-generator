package converter.graphical.table;

import javax.swing.table.DefaultTableModel;

public class CsvTableModel extends DefaultTableModel {

    private int rows = 30, cols = 3;

    private Object[] rowData = new Object[cols];

    public CsvTableModel() {
        super();
        initModelData();
    }

    private void initModelData() {

        for (int i = 0; i < cols; i++) {
            this.addColumn(Integer.toString(i));
        }

        for (int j = 0; j < rows; j++) {
            for (int i = 0; i < cols; i++) {
                rowData[i] = j + " | " + i;
            }
            this.addRow(rowData);
        }
    }

}
