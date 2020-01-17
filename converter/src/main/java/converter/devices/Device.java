package converter.devices;

import java.io.File;

public class Device {

    private String name;
    private File path;

    public Device(String name, File path) {
        this.name = name;
        this.path = path;
    }

    public String toString() {
        return name;
    }
}
