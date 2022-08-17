/*
 * ConversionTests.java
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
import androidx.test.filters.LargeTest;
import androidx.test.platform.app.InstrumentationRegistry;

import com.viliussutkus89.android.assetextractor.AssetExtractor;

import org.junit.BeforeClass;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.TimeUnit;


@LargeTest
@RunWith(Parameterized.class)
public class ConversionTests {
  private final File pdfFile;
  public ConversionTests(File pdfFile) {
    this.pdfFile = pdfFile;
  }

  @BeforeClass
  public static void setIdlingTimeout() {
    IdlingPolicies.setMasterPolicyTimeout(10, TimeUnit.MINUTES);
    IdlingPolicies.setIdlingResourceTimeout(10, TimeUnit.MINUTES);
  }

  @BeforeClass
  public static void extractPDFs() {
    Instrumentation instrumentation = InstrumentationRegistry.getInstrumentation();
    new AssetExtractor(instrumentation.getContext().getAssets())
            .setNoOverwrite()
            .extract(instrumentation.getTargetContext().getCacheDir(), "testPDFs");
  }

  @Parameterized.Parameters
  public static List<File> listPDFs() throws IOException {
    Instrumentation instrumentation = InstrumentationRegistry.getInstrumentation();
    File extractedToDir = new File(instrumentation.getTargetContext().getCacheDir(), "testPDFs");
    List<File> testFiles = new ArrayList<>();
    for(String testFilename: instrumentation.getContext().getAssets().list("testFiles")) {
        testFiles.add(new File(extractedToDir, testFilename));
    }
    return testFiles;
  }

  @Test
  public void convertPDF() throws pdf2htmlEX.ConversionFailedException, IOException {
    Context ctx = InstrumentationRegistry.getInstrumentation().getTargetContext();
    pdf2htmlEX converter = new pdf2htmlEX(ctx);

    File htmlFile = converter.convert(pdfFile);

    assertTrue("Converted HTML file not found! " + pdfFile.getName(), htmlFile.exists());
    assertTrue("Converted HTML file empty! " + pdfFile.getName(), htmlFile.length() > 0);

    htmlFile.delete();

    converter.close();
  }
}
