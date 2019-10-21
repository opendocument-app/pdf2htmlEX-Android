/*
 * pdf2htmlEX.java
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

package com.viliussutkus89.pdf2htmlex;

import android.content.Context;
import android.content.res.AssetManager;
import android.os.Build;
import android.util.Log;

import androidx.annotation.NonNull;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

public final class pdf2htmlEX {
  static {
    System.loadLibrary("pdf2htmlEX-android");
  }

  private static final String TAG = "pdf2htmlEX";

  // ExtractAssets adapted from
  // https://gist.github.com/tylerchesley/6198074
  private Boolean ExtractAssets(@NonNull AssetManager assetManager, @NonNull File outputDir, @NonNull String name) {
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
        if (!output_name.exists() && !output_name.mkdir()) {
          return false;
        }
        for (String asset: assets) {
          if (!ExtractAssets(assetManager, outputDir, name + File.separator + asset)) {
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

  private Boolean copyFile(InputStream input, OutputStream output) {
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

  private void prepareEnvironmentForFontforge(Context ctx) {
    File homeDir = new File(ctx.getCacheDir(), "homeForFontforge");
    homeDir.mkdir();

    File tmpDir = new File(ctx.getCacheDir(), "tmpdir");
    tmpDir.mkdir();

    String model = Build.MODEL;

    set_env_values_for_fontforge(homeDir.getAbsolutePath(), tmpDir.getAbsolutePath(), model);
  }

  private File m_pdf2htmlEX_dataDir;
  private File m_poppler_dataDir;
  private File m_pdf2htmlEX_tmpDir;
  private File m_outputHtmlsDir;

  public pdf2htmlEX(@NonNull Context ctx) {
    // pdf2htmlEX_dataDir is where pdf2htmlEX's share folder contents are
    m_pdf2htmlEX_dataDir = new File(ctx.getFilesDir(), "pdf2htmlEX");
    ExtractAssets(ctx.getAssets(), ctx.getFilesDir(), "pdf2htmlEX");

    // Poppler requires encoding data
    m_poppler_dataDir = new File(ctx.getFilesDir(), "poppler");
    ExtractAssets(ctx.getAssets(), ctx.getFilesDir(), "poppler");

    // tmpDir is where pdf2htmlEX does it's work
    m_pdf2htmlEX_tmpDir = new File(ctx.getCacheDir(), "pdf2htmlEX-tmp");
    m_pdf2htmlEX_tmpDir.mkdir();

    m_outputHtmlsDir = new File(m_pdf2htmlEX_tmpDir, "output-htmls");
    m_outputHtmlsDir.mkdir();

    prepareEnvironmentForFontforge(ctx);
  }

  public class ConversionFailedException extends Exception {
    public ConversionFailedException(String errorMessage) {
      super(errorMessage);
    }
  }

  // @TODO: patch pdf2htmlEX and poppler to use AssetManager in C++
  public File convert(@NonNull File inputPDF) throws IOException, ConversionFailedException {

    String inputFilenameNoPDFExt = inputPDF.getName();
    if (inputFilenameNoPDFExt.endsWith(".pdf")) {
      inputFilenameNoPDFExt = inputFilenameNoPDFExt.substring(0, inputFilenameNoPDFExt.length() - 4);
    }

    File outputHtml = new File(m_outputHtmlsDir, inputFilenameNoPDFExt + ".html");
    for (Integer i = 0; !outputHtml.createNewFile(); i++) {
      outputHtml = new File(m_outputHtmlsDir, inputFilenameNoPDFExt + "-" + i.toString() + ".html");
    }

    Integer retVal = call_pdf2htmlEX(m_pdf2htmlEX_dataDir.getAbsolutePath(),
      m_poppler_dataDir.getAbsolutePath(), m_pdf2htmlEX_tmpDir.getAbsolutePath(),
      inputPDF.getAbsolutePath(), outputHtml.getAbsolutePath());

    if (0 != retVal) {
      outputHtml.delete();
      throw new ConversionFailedException("Conversion failed. Return value from pdf2htmlEX: " + retVal.toString());
    }

    return outputHtml;
  }

  private native int call_pdf2htmlEX(String dataDir, String popplerDir, String tmpDir, String inputFile, String outputFile);

  // Because Java can't set env vars for the current process...
  private native void set_env_values_for_fontforge(String homeDir, String tmpDir, String username);
}