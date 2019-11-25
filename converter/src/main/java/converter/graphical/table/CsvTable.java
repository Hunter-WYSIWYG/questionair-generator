package converter.graphical.table;

import javax.swing.*;
import javax.swing.table.TableColumn;

public class CsvTable extends JTable {

    public CsvTable() {
        super(new CsvTableModel());
        setColumnWidth();
    }

    private void setColumnWidth() {
        for (int i = 0; i < this.getColumnCount(); i++) {
            TableColumn c = this.getColumnModel().getColumn(i);
            c.setPreferredWidth(5);
        }
    }
}
