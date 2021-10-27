/*
 * ConverterWorker.java
 *
 * Copyright (C) 2021 Vilius Sutkus'89
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

package com.viliussutkus89.android.pdf2htmlex.application;

import android.content.ContentResolver;
import android.content.Context;
import android.net.Uri;

import androidx.annotation.NonNull;
import androidx.work.Data;
import androidx.work.WorkInfo;
import androidx.work.Worker;
import androidx.work.WorkerParameters;

import com.viliussutkus89.android.pdf2htmlex.pdf2htmlEX;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

public class ConverterWorker extends Worker {
    public static final String INPUT__URI = "input__uri";
    public static final String INPUT__DESTINATION_DIR = "input__destination_dir";
    public static final String OUTPUT__URI = "output__uri";
    public static final String OUTPUT__PROGRESS = "STATE";

    public enum Progress {
        INIT,
        COPYING_INPUT,
        CONVERTING,
        UNKNOWN
    }

    public ConverterWorker(@NonNull Context context, @NonNull WorkerParameters workerParams) {
        super(context, workerParams);
        setProgress(Progress.INIT);
    }

    private void setProgress(Progress progress) {
        setProgressAsync(new Data.Builder().putInt(OUTPUT__PROGRESS, progress.ordinal()).build());
    }

    @NonNull
    public static Progress getProgress(@NonNull WorkInfo workInfo) {
        Data progress = workInfo.getProgress();
        int progressOrdinal = progress.getInt(OUTPUT__PROGRESS, -1);
        if (-1 == progressOrdinal) {
            return Progress.UNKNOWN;
        }
        try {
            return Progress.values()[progressOrdinal];
        } catch (ArrayIndexOutOfBoundsException ignored) {
            return Progress.UNKNOWN;
        }
    }

    @NonNull
    @Override
    public Result doWork() {
        final Uri inputUri = Uri.parse(getInputData().getString(INPUT__URI));
        if (null == inputUri) {
            return Result.failure();
        }

        final pdf2htmlEX converter = new pdf2htmlEX(getApplicationContext());
        if (isStopped()) {
            return Result.failure();
        }

        setProgress(Progress.COPYING_INPUT);
        final File inputFileInCache = copyUriToCache(getApplicationContext(), inputUri);
        if (null == inputFileInCache) {
            return Result.failure();
        }

        try {
            setProgress(Progress.CONVERTING);

            if (isStopped()) {
                return Result.failure();
            }
            File outputFile = converter.convert(inputFileInCache);

            String destinationDirStr = getInputData().getString(INPUT__DESTINATION_DIR);
            if (null != destinationDirStr) {
                final File destinationDir = new File(destinationDirStr);
                destinationDir.mkdir();
                final File outputFileInDestinationDir = generateNewFileInCache(destinationDir, outputFile.getName());
                if (null == outputFileInDestinationDir || !outputFile.renameTo(outputFileInDestinationDir)) {
                    outputFile.delete();
                    return Result.failure();
                }
                outputFile = outputFileInDestinationDir;
            }

            return Result.success(new Data.Builder().putString(OUTPUT__URI, outputFile.getAbsolutePath()).build());
        } catch (pdf2htmlEX.ConversionFailedException | IOException e) {
            return Result.failure();
        } finally {
            inputFileInCache.delete();
        }
    }

    private static File generateNewFileInCache(File cacheDir, String filename) {
        final String filenamePrefix;
        final String filenameSuffix;
        if (filename.endsWith(".pdf")) {
            filenamePrefix = filename.substring(0, filename.length() - ".pdf".length());
            filenameSuffix = ".pdf";
        }
        else if (filename.endsWith(".html")) {
            filenamePrefix = filename.substring(0, filename.length() - ".html".length());
            filenameSuffix = ".html";
        }
        else {
            filenamePrefix = filename;
            filenameSuffix = "";
        }

        File outputFileInCache = new File(cacheDir, filename);
        try {
            for (int i = 0; !outputFileInCache.createNewFile(); i++) {
                String filenameWithCounter = filenamePrefix + "-" + i + filenameSuffix;
                outputFileInCache = new File(cacheDir, filenameWithCounter);
            }
        } catch (IOException e) {
            return null;
        }
        return outputFileInCache;
    }

    private static File copyUriToCache(Context ctx, Uri input) {
        final ContentResolver contentResolver = ctx.getContentResolver();
        final String filename = GetFileName.FromUri(contentResolver, input);
        final File outputFileInCache = generateNewFileInCache(ctx.getCacheDir(), filename);
        if (null == outputFileInCache) {
            return null;
        }

        try (InputStream inputStream = contentResolver.openInputStream(input)) {
            try (OutputStream outputStream = new FileOutputStream(outputFileInCache)) {
                final int readBufferSize = 2048;
                final byte[] buffer = new byte[readBufferSize];

                int didRead;
                while (-1 != (didRead = inputStream.read(buffer, 0, readBufferSize))) {
                    outputStream.write(buffer, 0, didRead);
                }
            }
        } catch (IOException e) {
            outputFileInCache.delete();
            return null;
        }
        return outputFileInCache;
    }
}
