package com.viliussutkus89.android.pdf2htmlex.sampleapp;

import android.content.ContentResolver;
import android.database.Cursor;
import android.net.Uri;
import android.provider.OpenableColumns;

import java.io.File;

final class GetFileName {
    private GetFileName() {
    }

    // https://developer.android.com/training/secure-file-sharing/retrieve-info
    public static String FromUri(ContentResolver contentResolver, Uri uri) {
        if ("file".equals(uri.getScheme())) {
            return new File(uri.getPath()).getName();
        }

        try (Cursor crs = contentResolver.query(uri, null, null, null, null)) {
            if (null == crs) {
                return "UnknownFile";
            }
            crs.moveToFirst();
            int nameIndex = crs.getColumnIndex(OpenableColumns.DISPLAY_NAME);
            return (nameIndex >= 0) ? crs.getString(nameIndex) : "UnknownFile";
        }
    }
}
