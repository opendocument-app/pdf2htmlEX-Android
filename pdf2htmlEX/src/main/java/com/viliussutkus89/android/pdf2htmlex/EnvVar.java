package com.viliussutkus89.android.pdf2htmlex;

public class EnvVar {
    static {
        System.loadLibrary("envvar");
    }
    public static native void set(String key, String value);
}
