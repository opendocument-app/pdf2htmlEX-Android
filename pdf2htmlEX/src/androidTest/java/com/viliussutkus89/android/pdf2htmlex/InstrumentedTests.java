/*
 * InstrumentedTests.java
 *
 * Copyright (C) 2019,2020 Vilius Sutkus'89
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

  // PDFs must be placed in pdf2htmlEX/src/androidTest/assets/
  private final String[] m_PDFsToTest = new String[] {
          "fontfile3_opentype.pdf",
          "basic_text.pdf",
          "invalid_unicode_issue477.pdf",
          "pdf.pdf",
          "sample.pdf",
          "geneve_1564.pdf",
          "svg_background_with_page_rotation_issue402.pdf",
          "test_fail.pdf",
          "with_form.pdf",
          "text_visibility.pdf"
  };

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
  public void testAllSuppliedPDFs() throws IOException {
    Context ctx = InstrumentationRegistry.getInstrumentation().getTargetContext();

    pdf2htmlEX pdf2htmlEX = new pdf2htmlEX(ctx);

    for (String i: m_PDFsToTest) {
      File pdfFile = extractAssetPDF(i);
      File htmlFile;

      try {
        htmlFile = pdf2htmlEX.convert(pdfFile);
      } catch (IOException | pdf2htmlEX.ConversionFailedException e) {
        pdfFile.delete();
        e.printStackTrace();
        fail("Failed to convert PDF to HTML: " + i);
        continue;
      }

      pdfFile.delete();
      assertTrue("Converted HTML file not found! " + i, htmlFile.exists());
      assertTrue("Converted HTML file empty! " + i, htmlFile.length() > 0);

      htmlFile.delete();
    }
  }

  @Test
  public void encryptedPdfTest() throws IOException {
    // encrypted_fontfile3_opentype.pdf was generated using:
    // qpdf --encrypt sample-user-password sample-owner-password 256 -- fontfile3_opentype.pdf encrypted_fontfile3_opentype.pdf
    File pdfFile = extractAssetPDF("encrypted_fontfile3_opentype.pdf");

    pdf2htmlEX converter = new pdf2htmlEX(InstrumentationRegistry.getInstrumentation().getTargetContext());
    converter.setInputPDF(pdfFile);

    try {
      converter.convert().delete();
      fail("Conversion succeeded when it should have failed because of no password!");
    } catch (pdf2htmlEX.PasswordRequiredException ignored) {
    } catch (IOException | pdf2htmlEX.ConversionFailedException e) {
      e.printStackTrace();
      fail("Encrypted pdf conversion failed!");
    }

    try {
      converter.setUserPassword("wrong-user-password").convert().delete();
      fail("Conversion succeeded when it should have failed because of wrong user password!");
    } catch (pdf2htmlEX.WrongPasswordException ignored) {
    } catch (IOException | pdf2htmlEX.ConversionFailedException e) {
      e.printStackTrace();
      fail("Encrypted pdf conversion failed!");
    }
    converter.setUserPassword("");

    try {
      converter.setOwnerPassword("wrong-owner-password").convert().delete();
      fail("Conversion succeeded when it should have failed because of wrong user password!");
    } catch (pdf2htmlEX.WrongPasswordException ignored) {
    } catch (IOException | pdf2htmlEX.ConversionFailedException e) {
      e.printStackTrace();
      fail("Encrypted pdf conversion failed!");
    }
    converter.setOwnerPassword("");

    try {
      File htmlFile = converter.setUserPassword("sample-user-password").convert();
      assertTrue("Converted HTML file not found!", htmlFile.exists());
      assertTrue("Converted HTML file empty!", htmlFile.length() > 0);
      htmlFile.delete();
    } catch (IOException | pdf2htmlEX.ConversionFailedException e) {
      e.printStackTrace();
      fail("Encrypted pdf conversion failed!");
    }
    converter.setUserPassword("");

    try {
      File htmlFile = converter.setOwnerPassword("sample-owner-password").convert();
      assertTrue("Converted HTML file not found!", htmlFile.exists());
      assertTrue("Converted HTML file empty!", htmlFile.length() > 0);
      htmlFile.delete();
    } catch (IOException | pdf2htmlEX.ConversionFailedException e) {
      e.printStackTrace();
      fail("Encrypted pdf conversion failed!");
    }
    converter.setOwnerPassword("");

    try {
      File htmlFile = converter.setUserPassword("sample-user-password").setOwnerPassword("wrong-owner-password"). convert();
      assertTrue("Converted HTML file not found!", htmlFile.exists());
      assertTrue("Converted HTML file empty!", htmlFile.length() > 0);
      htmlFile.delete();
    } catch (IOException | pdf2htmlEX.ConversionFailedException e) {
      e.printStackTrace();
      fail("Encrypted pdf conversion failed!");
    }
    converter.setUserPassword("");
    converter.setOwnerPassword("");

    try {
      File htmlFile = converter.setUserPassword("wrong-user-password").setOwnerPassword("sample-owner-password"). convert();
      assertTrue("Converted HTML file not found!", htmlFile.exists());
      assertTrue("Converted HTML file empty!", htmlFile.length() > 0);
      htmlFile.delete();
    } catch (IOException | pdf2htmlEX.ConversionFailedException e) {
      e.printStackTrace();
      fail("Encrypted pdf conversion failed!");
    }
    converter.setUserPassword("");
    converter.setOwnerPassword("");

    try {
      File htmlFile = converter.setUserPassword("sample-user-password").setOwnerPassword("sample-owner-password").convert();
      assertTrue("Converted HTML file not found!", htmlFile.exists());
      assertTrue("Converted HTML file empty!", htmlFile.length() > 0);
      htmlFile.delete();
    } catch (IOException | pdf2htmlEX.ConversionFailedException e) {
      e.printStackTrace();
      fail("Encrypted pdf conversion failed!");
    }

    pdfFile.delete();
  }

}
