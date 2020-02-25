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

package com.viliussutkus89.android.pdf2htmlex;

import android.content.Context;
import android.os.Build;

import androidx.annotation.NonNull;

import java.io.File;
import java.io.IOException;

public final class pdf2htmlEX {
  static {
    System.loadLibrary("pdf2htmlEX-android");
  }

  private static final String TAG = "pdf2htmlEX";

  private File m_pdf2htmlEX_dataDir;
  private File m_poppler_dataDir;
  private File m_pdf2htmlEX_tmpDir;
  private File m_outputHtmlsDir;

  private File p_inputPDF;
  private String p_ownerPassword = "";
  private String p_userPassword = "";
  private boolean p_outline = true;
  private boolean p_drm = true;
  private String p_backgroundFormat = "";

  public static class ConversionFailedException extends Exception {
    public ConversionFailedException(String errorMessage) {
      super(errorMessage);
    }
  }

  public static class PasswordRequiredException extends ConversionFailedException {
    public PasswordRequiredException(String errorMessage) {
      super(errorMessage);
    }
  }

  public static class WrongPasswordException extends ConversionFailedException {
    public WrongPasswordException(String errorMessage) {
      super(errorMessage);
    }
  }

  public static class CopyProtectionException extends ConversionFailedException {
    public CopyProtectionException(String errorMessage) {
      super(errorMessage);
    }
  }

  private synchronized void init(@NonNull Context ctx) {
    File filesDir = ctx.getFilesDir();
    File cacheDir = ctx.getCacheDir();
    // @TODO: https://github.com/ViliusSutkus89/pdf2htmlEX-Android/issues/9
    // pdf2htmlEX_dataDir is where pdf2htmlEX's share folder contents are
    m_pdf2htmlEX_dataDir = new File(filesDir, "pdf2htmlEX");
    if (!m_pdf2htmlEX_dataDir.exists()) {
      AssetExtractor.extract(ctx.getAssets(), filesDir, "pdf2htmlEX");
    }

    // @TODO: https://github.com/ViliusSutkus89/pdf2htmlEX-Android/issues/10
    // Poppler requires encoding data
    m_poppler_dataDir = new File(filesDir, "poppler");
    if (!m_poppler_dataDir.exists()) {
      AssetExtractor.extract(ctx.getAssets(), filesDir, "poppler");
    }

    // tmpDir is where pdf2htmlEX does it's work
    m_pdf2htmlEX_tmpDir = new File(cacheDir, "pdf2htmlEX-tmp");
    m_pdf2htmlEX_tmpDir.mkdir();

    m_outputHtmlsDir = new File(m_pdf2htmlEX_tmpDir, "output-htmls");
    m_outputHtmlsDir.mkdir();

    File homeDir = new File(cacheDir, "homeForFontforge");
    homeDir.mkdir();

    File tmpDir = new File(cacheDir, "tmpdir");
    tmpDir.mkdir();

    set_environment_value("HOME", homeDir.getAbsolutePath());
    set_environment_value("TMPDIR", tmpDir.getAbsolutePath());
    set_environment_value("USER", Build.MODEL);

    FontconfigAndroid.init(ctx.getAssets(), cacheDir, filesDir);
  }

  public pdf2htmlEX(@NonNull Context ctx) {
    init(ctx);
  }

  public pdf2htmlEX setInputPDF(@NonNull File inputPDF) {
    this.p_inputPDF = inputPDF;
    return this;
  }

  public File convert(@NonNull File inputPDF) throws IOException, ConversionFailedException {
    setInputPDF(inputPDF);
    return convert();
  }

  public pdf2htmlEX setOwnerPassword(@NonNull String ownerPassword) {
    this.p_ownerPassword = ownerPassword;
    return this;
  }

  public pdf2htmlEX setUserPassword(@NonNull String userPassword) {
    this.p_userPassword = userPassword;
    return this;
  }

  public pdf2htmlEX setOutline(@NonNull boolean enableOutline) {
    this.p_outline = enableOutline;
    return this;
  }

  public pdf2htmlEX setDRM(@NonNull boolean enableDRM) {
    this.p_drm = enableDRM;
    return this;
  }

  /**
   *  @param backgroundFormat: png (default), jpg or svg
   */
  public pdf2htmlEX setBackgroundFormat(@NonNull String backgroundFormat) {
    this.p_backgroundFormat = backgroundFormat;
    return this;
  }

  /*
   * @deprecated pdf2htmlEX-Android doesn't fork anymore
   */
  @Deprecated
  public void setNoForking(boolean thisArgumentIsIgnored) { }

  public File convert() throws IOException, ConversionFailedException {
    if (null == this.p_inputPDF) {
      throw new ConversionFailedException("No Input PDF given!");
    }

    if (!this.p_inputPDF.exists()) {
      throw new ConversionFailedException("Input PDF does not exist!");
    }

    String inputFilenameNoPDFExt = this.p_inputPDF.getName();
    if (inputFilenameNoPDFExt.endsWith(".pdf")) {
      inputFilenameNoPDFExt = inputFilenameNoPDFExt.substring(0, inputFilenameNoPDFExt.length() - 4);
    }

    File outputHtml = new File(m_outputHtmlsDir, inputFilenameNoPDFExt + ".html");
    for (Integer i = 0; !outputHtml.createNewFile(); i++) {
      outputHtml = new File(m_outputHtmlsDir, inputFilenameNoPDFExt + "-" + i.toString() + ".html");
    }

    Integer retVal = call_pdf2htmlEX(m_pdf2htmlEX_dataDir.getAbsolutePath(),
      m_poppler_dataDir.getAbsolutePath(), m_pdf2htmlEX_tmpDir.getAbsolutePath(),
      this.p_inputPDF.getAbsolutePath(), outputHtml.getAbsolutePath(),
      this.p_ownerPassword, this.p_userPassword, this.p_outline, this.p_drm,
      this.p_backgroundFormat
    );

    // retVal values defined in pdf2htmlEX.cc
    if (0 != retVal) {
      outputHtml.delete();
      if (2 == retVal) {
        if (this.p_ownerPassword.isEmpty() && this.p_userPassword.isEmpty()) {
          throw new PasswordRequiredException("Password is required to decrypt this encrypted document!");
        } else {
          throw new WrongPasswordException("Wrong password is supplied to decrypt this encrypted document!");
        }
      } else if (3 == retVal) {
        throw new CopyProtectionException("Document is copy protected!");
      } else {
        throw new ConversionFailedException("Return value from pdf2htmlEX: " + retVal);
      }
    }
    return outputHtml;
  }

  private native int call_pdf2htmlEX(String dataDir, String popplerDir, String tmpDir, String inputFile, String outputFile, String ownerPassword, String userPassword, boolean outline, boolean drm, String backgroundFormat);

  // Because Java cannot setenv for the current process
  static native void set_environment_value(String key, String value);
}
