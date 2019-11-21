/*
 * InstrumentedTests.java
 *
 * Copyright (C) 2019 Vilius Sutkus'89
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

package com.viliussutkus89.android.pdf2htmlex;

import android.app.Instrumentation;
import android.content.Context;

import androidx.test.ext.junit.runners.AndroidJUnit4;
import androidx.test.platform.app.InstrumentationRegistry;

import org.junit.Test;
import org.junit.runner.RunWith;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

@RunWith(AndroidJUnit4.class)
public class InstrumentedTests {

  private File extractAssetPDF(String filename) throws IOException {
    Instrumentation instrumentation = InstrumentationRegistry.getInstrumentation();
    Context appContext = instrumentation.getTargetContext();
    File mInputDir = new File(appContext.getCacheDir(), "PDFs-extracted-from-assets");
    if (!mInputDir.mkdir()) {
      assertTrue("Failed to create folder for input PDFs", mInputDir.exists());
    }

    Context testContext = instrumentation.getContext();
    InputStream is = testContext.getAssets().open(filename);
    File fileInCache = new File(mInputDir, filename);
    copyFile(is, new FileOutputStream(fileInCache));
    assertTrue("Failed to copy input PDF", fileInCache.exists());
    return fileInCache;
  }

  private void copyFile(InputStream input, OutputStream output) throws IOException {
    final int buffer_size = 1024;
    byte[] buffer = new byte[buffer_size];

    BufferedInputStream in = new BufferedInputStream(input, buffer_size);
    BufferedOutputStream out = new BufferedOutputStream(output, buffer_size);

    int haveRead;
    while (-1 != (haveRead = in.read(buffer))) {
      out.write(buffer, 0, haveRead);
    }
    out.flush();
    out.close();
    output.close();
    in.close();
    input.close();
  }

  @Test
  public synchronized void conversionTest() {
    File pdfFile, htmlFile;
    try {
      pdfFile = extractAssetPDF("fontfile3_opentype.pdf");
    } catch (IOException e) {
      e.printStackTrace();
      fail("Failed to extract PDF from assets");
      return;
    }

    pdf2htmlEX converter = new pdf2htmlEX(InstrumentationRegistry.getInstrumentation().getTargetContext());
    try {
      htmlFile = converter.convert(pdfFile);
    } catch (IOException e) {
      e.printStackTrace();
      fail("Failed to convert PDF to HTML");
      return;
    } catch (pdf2htmlEX.ConversionFailedException e) {
      e.printStackTrace();
      fail("Failed to convert PDF to HTML");
      return;
    }
    assertTrue("Converted HTML file not found!", htmlFile.exists());
    assertTrue("Converted HTML file empty!", htmlFile.length() > 0);
  }

  @Test
  public void conversionTwiceTest() {
    conversionTest();
    conversionTest();
  }

}
