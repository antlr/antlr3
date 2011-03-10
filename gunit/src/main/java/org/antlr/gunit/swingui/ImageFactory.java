package org.antlr.gunit.swingui;

import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.swing.ImageIcon;

public class ImageFactory {

    private static ImageFactory singleton ;

    public static ImageFactory getSingleton() {
        if(singleton == null) singleton = new ImageFactory();
        return singleton;
    }

    private ImageFactory() {
        ACCEPT = getImage("accept.png");
        ADD = getImage("add.png");
        DELETE = getImage("delete24.png");
        TEXTFILE = getImage("textfile24.png");
        TEXTFILE16 = getImage("textfile16.png");
        ADDFILE = getImage("addfile24.png");
        WINDOW16 = getImage("windowb16.png");
        FAV16 = getImage("favb16.png");
        SAVE = getImage("floppy24.png");
        OPEN = getImage("folder24.png");
        EDIT16 = getImage("edit16.png");
        FILE16 = getImage("file16.png");
        RUN_PASS = getImage("runpass.png");
        RUN_FAIL = getImage("runfail.png");
        TESTSUITE = getImage("testsuite.png");
        TESTGROUP = getImage("testgroup.png");
        TESTGROUPX = getImage("testgroupx.png");
        NEXT = getImage("next24.png");
    }
    
    private ImageIcon getImage(String name) {
        name = IMG_DIR + name;
        try {
            final ClassLoader loader = ImageFactory.class.getClassLoader();
            final InputStream in = loader.getResourceAsStream(name);
            final byte[] data = new byte[in.available()];
            in.read(data);
            in.close();
            return new ImageIcon(data);
        } catch (IOException ex) {
            System.err.println("Can't load image file: " + name);
            System.exit(1);
        } catch(RuntimeException e) {
            System.err.println("Can't load image file: " + name);
            System.exit(1);
        }
        return null;
    }
    
    private static final String IMG_DIR = "org/antlr/gunit/swingui/images/";

    public ImageIcon ACCEPT;
    public ImageIcon ADD;
    public ImageIcon DELETE;
    public ImageIcon TEXTFILE ;
    public ImageIcon ADDFILE;

    public ImageIcon TEXTFILE16 ;
    public ImageIcon WINDOW16;
    public ImageIcon FAV16;
    public ImageIcon SAVE ;

    public ImageIcon OPEN ;
    public ImageIcon EDIT16;
    public ImageIcon FILE16;
    public ImageIcon NEXT;

    public ImageIcon RUN_PASS;
    public ImageIcon RUN_FAIL;
    public ImageIcon TESTSUITE;
    public ImageIcon TESTGROUP ;
    public ImageIcon TESTGROUPX;

}
