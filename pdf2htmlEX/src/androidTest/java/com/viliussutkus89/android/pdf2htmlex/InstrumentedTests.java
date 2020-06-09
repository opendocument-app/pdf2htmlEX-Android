/*
 * InstrumentedTests.java
 *
 * Copyright (C) 2019, 2020 Vilius Sutkus'89
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

import com.viliussutkus89.android.assetextractor.AssetExtractor;

import org.junit.BeforeClass;
import org.junit.Test;
import org.junit.runner.RunWith;

import java.io.File;
import java.io.IOException;

import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

@RunWith(AndroidJUnit4.class)
public class InstrumentedTests {

  @BeforeClass
  public static void extractPDFs() {
    Instrumentation instrumentation = InstrumentationRegistry.getInstrumentation();

    Context testCtx = instrumentation.getContext();
    AssetExtractor ae = new AssetExtractor(testCtx.getAssets()).setNoOverwrite();

    Context appCtx = instrumentation.getTargetContext();
    File cacheDir = appCtx.getCacheDir();
    ae.extract(cacheDir, "testPDFs");
    ae.extract(cacheDir, "encrypted_fontfile3_opentype.pdf");
  }

  @Test
  public void testAllSuppliedPDFs() throws IOException {
    Context ctx = InstrumentationRegistry.getInstrumentation().getTargetContext();
    testAllSuppliedPDFs(new pdf2htmlEX(ctx), ctx);
  }

  @Test
  public void testAllSuppliedPDFs_exe() throws IOException {
    Context ctx = InstrumentationRegistry.getInstrumentation().getTargetContext();
    testAllSuppliedPDFs(new pdf2htmlEX_exe(ctx), ctx);
  }

  public void testAllSuppliedPDFs(pdf2htmlEX converter, Context ctx) throws IOException {
    File testPDFDir = new File(ctx.getCacheDir(), "testPDFs");
    for (File pdfFile: testPDFDir.listFiles()) {
      File htmlFile;

      try {
        htmlFile = converter.convert(pdfFile);
      } catch (IOException | pdf2htmlEX.ConversionFailedException e) {
        e.printStackTrace();
        fail("Failed to convert PDF to HTML: " + pdfFile.getName() + " : " + e.getMessage());
        continue;
      }

      assertTrue("Converted HTML file not found! " + pdfFile.getName(), htmlFile.exists());
      assertTrue("Converted HTML file empty! " + pdfFile.getName(), htmlFile.length() > 0);

      htmlFile.delete();
    }
  }

  @Test
  public void encryptedPdfTest() throws IOException {
    Context ctx = InstrumentationRegistry.getInstrumentation().getTargetContext();
    encryptedPdfTest(new pdf2htmlEX(ctx), ctx);
  }

  @Test
  public void encryptedPdfTest_exe() throws IOException {
    Context ctx = InstrumentationRegistry.getInstrumentation().getTargetContext();
    encryptedPdfTest(new pdf2htmlEX_exe(ctx), ctx);
  }

  public void encryptedPdfTest(pdf2htmlEX converter, Context ctx) throws IOException {
    // encrypted_fontfile3_opentype.pdf was generated using:
    // qpdf --encrypt sample-user-password sample-owner-password 256 -- fontfile3_opentype.pdf encrypted_fontfile3_opentype.pdf
    File pdfFile = new File(ctx.getCacheDir(), "encrypted_fontfile3_opentype.pdf");

    converter.setInputPDF(pdfFile);

    try {
      converter.convert().delete();
      fail("Conversion succeeded when it should have failed because of no password!");
    } catch (pdf2htmlEX.PasswordRequiredException ignored) {
    } catch (IOException | pdf2htmlEX.ConversionFailedException e) {
      e.printStackTrace();
      fail("Encrypted pdf conversion failed: " + e.getMessage());
    }

    try {
      converter.setUserPassword("wrong-user-password").convert().delete();
      fail("Conversion succeeded when it should have failed because of wrong user password!");
    } catch (pdf2htmlEX.WrongPasswordException ignored) {
    } catch (IOException | pdf2htmlEX.ConversionFailedException e) {
      e.printStackTrace();
      fail("Encrypted pdf conversion failed: " + e.getMessage());
    }
    converter.setUserPassword("");

    try {
      converter.setOwnerPassword("wrong-owner-password").convert().delete();
      fail("Conversion succeeded when it should have failed because of wrong owner password!");
    } catch (pdf2htmlEX.WrongPasswordException ignored) {
    } catch (IOException | pdf2htmlEX.ConversionFailedException e) {
      e.printStackTrace();
      fail("Encrypted pdf conversion failed: " + e.getMessage());
    }
    converter.setOwnerPassword("");

    try {
      File htmlFile = converter.setUserPassword("sample-user-password").convert();
      assertTrue("Converted HTML file not found!", htmlFile.exists());
      assertTrue("Converted HTML file empty!", htmlFile.length() > 0);
      htmlFile.delete();
    } catch (IOException | pdf2htmlEX.ConversionFailedException e) {
      e.printStackTrace();
      fail("Encrypted pdf conversion failed: " + e.getMessage());
    }
    converter.setUserPassword("");

    try {
      File htmlFile = converter.setOwnerPassword("sample-owner-password").convert();
      assertTrue("Converted HTML file not found!", htmlFile.exists());
      assertTrue("Converted HTML file empty!", htmlFile.length() > 0);
      htmlFile.delete();
    } catch (IOException | pdf2htmlEX.ConversionFailedException e) {
      e.printStackTrace();
      fail("Encrypted pdf conversion failed: " + e.getMessage());
    }
    converter.setOwnerPassword("");

    try {
      File htmlFile = converter.setUserPassword("sample-user-password").setOwnerPassword("wrong-owner-password"). convert();
      assertTrue("Converted HTML file not found!", htmlFile.exists());
      assertTrue("Converted HTML file empty!", htmlFile.length() > 0);
      htmlFile.delete();
    } catch (IOException | pdf2htmlEX.ConversionFailedException e) {
      e.printStackTrace();
      fail("Encrypted pdf conversion failed: " + e.getMessage());
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
      fail("Encrypted pdf conversion failed: " + e.getMessage());
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
      fail("Encrypted pdf conversion failed: " + e.getMessage());
    }
  }

}
