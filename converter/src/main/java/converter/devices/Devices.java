package converter.devices;

import javax.swing.filechooser.FileSystemView;
import java.io.File;
import java.util.ArrayList;

public class Devices {

    public static ArrayList<Device> getDevices() {
        File[] paths = File.listRoots();
        ArrayList<Device> devices = new ArrayList<>();

        for (File path : paths) {
            FileSystemView fileSystemView = FileSystemView.getFileSystemView();
            String name = fileSystemView.getSystemDisplayName(path);
            Device device = new Device(name, path);
            devices.add(device);
        }

        return devices;
    }
}
