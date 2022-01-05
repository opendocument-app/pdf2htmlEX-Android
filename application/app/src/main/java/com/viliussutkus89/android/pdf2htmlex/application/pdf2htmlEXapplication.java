package com.viliussutkus89.android.pdf2htmlex.application;

import android.app.Application;

import androidx.annotation.NonNull;
import androidx.work.Configuration;

public class pdf2htmlEXapplication extends Application implements Configuration.Provider {
    @NonNull
    @Override
    public Configuration getWorkManagerConfiguration() {
        return new Configuration.Builder()
                .setDefaultProcessName(getPackageName())
                .build();
    }
}
