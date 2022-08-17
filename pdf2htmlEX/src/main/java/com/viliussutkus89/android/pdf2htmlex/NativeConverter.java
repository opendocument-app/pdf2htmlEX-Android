package com.viliussutkus89.android.pdf2htmlex;

import java.io.Closeable;
import java.io.File;

class NativeConverter implements Closeable {
    long mConverter;

    static native long createNewConverterObject(String tmpDir, String dataDir, String popplerDir);
    NativeConverter(File tmpDir, File dataDir, File popplerDataDir) {
        mConverter = createNewConverterObject(
                tmpDir.getAbsolutePath(),
                dataDir.getAbsolutePath(),
                popplerDataDir.getAbsolutePath()
        );
    }

    private static native void dealloc(long converter);
    @Override
    public void close() {
        dealloc(mConverter);
        mConverter = 0;
    }

    static native int convert(long converter);
    static native void setInputFile(long converter, String inputFile);
    static native void setOutputFile(long converter, String outputFile);
    static native void setOwnerPassword(long converter, String ownerPassword);
    static native void setUserPassword(long converter, String userPassword);
    static native void setOutline(long converter, Boolean enable);
    static native void setDrm(long converter, Boolean enable);
    static native void setEmbedFont(long converter, Boolean embed);
    static native void setEmbedExternalFont(long converter, Boolean embed);
    static native void setProcessAnnotation(long converter, Boolean process);
    static native void setBackgroundFormat(long converter, String backgroundFormat);
}
