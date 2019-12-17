package com.viliussutkus89.android.pdf2htmlex;

import android.content.res.AssetManager;
import android.util.Log;

import androidx.annotation.NonNull;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

final class AssetExtractor {
    private static final String TAG = "AssetExtractor";

    // ExtractAssets adapted from
    // https://gist.github.com/tylerchesley/6198074
    static Boolean extract(@NonNull AssetManager assetManager, @NonNull File outputDir, @NonNull String name) {
        File output_name = new File(outputDir, name);
        try {
            String[] assets = assetManager.list(name);
            if (0 == assets.length) { // Processing a file
                InputStream in = assetManager.open(name);
                OutputStream out = new FileOutputStream(output_name);
                if (!copyFile(in, out)) {
                    return false;
                }
            } else { // Processing a folder
                if (!output_name.exists() && !output_name.mkdirs()) {
                    return false;
                }
                for (String asset: assets) {
                    if (!extract(assetManager, outputDir, name + File.separator + asset)) {
                        return false;
                    }
                }
            }
        } catch (IOException e) {
            Log.e(TAG, e.getMessage());
            return false;
        }
        return true;
    }

    private static Boolean copyFile(InputStream input, OutputStream output) {
        final int buffer_size = 1024;
        byte[] buffer = new byte[buffer_size];

        BufferedInputStream in = new BufferedInputStream(input, buffer_size);
        BufferedOutputStream out = new BufferedOutputStream(output, buffer_size);

        try {
            int read;
            while (-1 != (read = in.read(buffer))) {
                out.write(buffer, 0, read);
            }
            out.flush();
            out.close();
            output.close();
            in.close();
            input.close();
        } catch (IOException e) {
            Log.e(TAG, e.getMessage());
            return false;
        }
        return true;
    }
}
