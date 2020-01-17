package converter.graphical.ui;

import converter.devices.Device;
import converter.devices.Devices;

import javax.swing.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.ArrayList;

public class Menu {

    private static JMenuBar menuBar;
    private static JMenu chooseDevice;
    private static Device selectedDevice;
    private static ArrayList<JRadioButtonMenuItem> deviceItems;
    private static ArrayList<Device> devices;

    /**
     * Initiates the menu for selecting devices.
     */
    private static void initMenu() {
        menuBar = new JMenuBar();
        JMenu menu = new JMenu("Gerät");
        chooseDevice = new JMenu("Gerät auswählen");
        JMenuItem uploadAPK = new JMenuItem("APK hochladen");

        ActionListener refreshSelected = new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {

            }
        };

        JMenuItem refresh = new JMenuItem("Aktualisieren");
        chooseDevice.add(refresh);

        devices = Devices.getDevices();
        deviceItems = new ArrayList<>();
        ButtonGroup radioButtonsGroup = new ButtonGroup();

        ActionListener deviceSelected = new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                int deviceNumber = Integer.parseInt(e.getActionCommand().split(". ")[0]) - 1;
                Menu.selectedDevice = devices.get(deviceNumber);
            }
        };

        for (int deviceCounter = 0; deviceCounter < devices.size(); deviceCounter++) {
            Device device = devices.get(deviceCounter);
            JRadioButtonMenuItem deviceItem = new JRadioButtonMenuItem((deviceCounter + 1) + ". " + device.toString());
            deviceItem.addActionListener(deviceSelected);
            deviceItems.add(deviceItem);
            radioButtonsGroup.add(deviceItem);
            chooseDevice.add(deviceItem);
        }

        menu.add(chooseDevice);
        menu.add(uploadAPK);
        menuBar.add(menu);
    }

    public static JMenuBar getMenuBar() {
        if (menuBar == null) {
            initMenu();
        }

        return menuBar;
    }
}
