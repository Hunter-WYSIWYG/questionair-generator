import java.awt.FlowLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JTextField;

public class GUI extends JFrame {
	
	//grafische Elemente + Parser anlegen
	private JLabel label1;
	private JLabel label2;
	private JTextField textfield1;
	private JButton button1;
	private Parser parser;
	
	public GUI(String title, String sourceFile, String targetFile) {
		
		setTitle(title);
		setDefaultCloseOperation(EXIT_ON_CLOSE);
		setLayout(new FlowLayout());
		
		setSize(280, 100);
		setResizable(false);
		
		//grafische Elemente + Funktionalität initialisieren
		initComponents(sourceFile, targetFile);
		
		//grafische Elemente hinzufügen
		add(label1);
		add(label2);
		add(textfield1);
		add(button1);
		
		setLocationRelativeTo(null); //immer mittig im Bildschirm starten
		setVisible(true);
		
	}
	
	private void initComponents(String sourceFile, String targetFile) {
		
		label1 = new JLabel("        label_1                           ");
		label2 = new JLabel("label_2");
		textfield1 = new JTextField(8);
		button1 = new JButton("Code ausführen");
		parser = new Parser(sourceFile, targetFile);
		button1.addActionListener(new ActionListener() {
			
			@Override
			public void actionPerformed(ActionEvent e) {
				
				parser.parsing();
				
			}
		});
		
		
	}
	
}
