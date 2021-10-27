/*
 * SaveWorker.java
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
import androidx.work.Worker;
import androidx.work.WorkerParameters;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

public class SaveWorker extends Worker {
    static final String INPUT__INPUT_URI = "input__input_uri";
    static final String INPUT__OUTPUT_URI = "input__output_uri";

    public SaveWorker(@NonNull Context context, @NonNull WorkerParameters workerParams) {
        super(context, workerParams);
    }

    @NonNull
    @Override
    public Result doWork() {
        final Uri inputUri = Uri.parse(getInputData().getString(INPUT__INPUT_URI));
        final Uri outputUri = Uri.parse(getInputData().getString(INPUT__OUTPUT_URI));
        if (null == inputUri || null == outputUri) {
            return Result.failure();
        }

        ContentResolver contentResolver = getApplicationContext().getContentResolver();

        try (InputStream inputStream = contentResolver.openInputStream(inputUri)) {
            try (OutputStream outputStream = contentResolver.openOutputStream(outputUri)) {
                final int readBufferSize = 2048;
                final byte[] buffer = new byte[readBufferSize];

                int didRead;
                while (-1 != (didRead = inputStream.read(buffer, 0, readBufferSize))) {
                    outputStream.write(buffer, 0, didRead);
                }
            }
        } catch (IOException e) {
            return Result.failure();
        }

        return Result.success();
    }
}
