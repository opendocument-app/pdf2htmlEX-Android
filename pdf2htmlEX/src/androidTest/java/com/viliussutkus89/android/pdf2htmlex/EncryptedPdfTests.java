/*
 * EncryptedPdfTests.java
 *
 * Copyright (C) 2019, 2020, 2022 ViliusSutkus89.com
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

import static org.junit.Assert.assertTrue;

import android.app.Instrumentation;
import android.content.Context;

import androidx.test.espresso.IdlingPolicies;
import androidx.test.ext.junit.runners.AndroidJUnit4;
import androidx.test.filters.LargeTest;
import androidx.test.platform.app.InstrumentationRegistry;

import com.viliussutkus89.android.assetextractor.AssetExtractor;

import org.junit.After;
import org.junit.BeforeClass;
import org.junit.Test;
import org.junit.runner.RunWith;

import java.io.File;
import java.util.concurrent.TimeUnit;


@LargeTest
@RunWith(AndroidJUnit4.class)
public class EncryptedPdfTests {

  @BeforeClass
  public static void setIdlingTimeout() {
    IdlingPolicies.setMasterPolicyTimeout(10, TimeUnit.MINUTES);
    IdlingPolicies.setIdlingResourceTimeout(10, TimeUnit.MINUTES);
  }

  @BeforeClass
  public static void extractPDF() {
    Instrumentation instrumentation = InstrumentationRegistry.getInstrumentation();
    new AssetExtractor(instrumentation.getContext().getAssets())
            .setNoOverwrite()
            .extract(instrumentation.getTargetContext().getCacheDir(), "encrypted_fontfile3_opentype.pdf");
  }

  private final Context ctx = InstrumentationRegistry.getInstrumentation().getTargetContext();

  // encrypted_fontfile3_opentype.pdf was generated using:
  // qpdf --encrypt sample-user-password sample-owner-password 256 -- fontfile3_opentype.pdf encrypted_fontfile3_opentype.pdf
  private final File pdfFile = new File(ctx.getCacheDir(), "encrypted_fontfile3_opentype.pdf");

  private final pdf2htmlEX converter = new pdf2htmlEX(ctx).setInputPDF(pdfFile);

  private File convertedHtml = null;
  @After
  public void cleanUp() {
    if (null != convertedHtml) {
      assertTrue("Converted HTML file not found!", convertedHtml.exists());
      assertTrue("Converted HTML file empty!", convertedHtml.length() > 0);
      convertedHtml.delete();
    }
    converter.close();
  }

  @Test(expected = pdf2htmlEX.PasswordRequiredException.class)
  public void PasswordRequiredExceptionTest() throws Exception {
    converter.convert();
  }

  @Test(expected = pdf2htmlEX.WrongPasswordException.class)
  public void WrongUserPasswordExceptionTest() throws Exception {
    converter.setUserPassword("wrong-user-password")
      .convert();
  }

  @Test(expected = pdf2htmlEX.WrongPasswordException.class)
  public void WrongOwnerPasswordExceptionTest() throws Exception {
    converter.setOwnerPassword("wrong-owner-password")
      .convert();
  }

  @Test
  public void CorrectUserPasswordTest() throws Exception {
    convertedHtml = converter.setUserPassword("sample-user-password")
      .convert();
  }

  @Test
  public void CorrectOwnerPasswordTest() throws Exception {
    convertedHtml = converter.setOwnerPassword("sample-owner-password")
      .convert();
  }

  @Test
  public void CorrectUserPasswordWrongOwnerPasswordTest() throws Exception {
    convertedHtml = converter
      .setUserPassword("sample-user-password")
      .setOwnerPassword("wrong-owner-password")
      .convert();
  }

  @Test
  public void WrongUserPasswordCorrectOwnerPasswordTest() throws Exception {
    convertedHtml = converter
      .setUserPassword("wrong-user-password")
      .setOwnerPassword("sample-owner-password")
      .convert();
  }

  @Test
  public void CorrectUserAndOwnerPasswordsTest() throws Exception {
    convertedHtml = converter
      .setUserPassword("sample-user-password")
      .setOwnerPassword("sample-owner-password")
      .convert();
  }
}
