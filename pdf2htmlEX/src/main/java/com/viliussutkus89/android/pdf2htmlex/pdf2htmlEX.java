/*
 * pdf2htmlEX.java
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

import android.content.Context;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.viliussutkus89.android.assetextractor.AssetExtractor;

import java.io.File;
import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.Map;

public class pdf2htmlEX {
  static private final Object s_initSynchronizer = new Object();

  final Map<String, String> m_environment = new LinkedHashMap<>();

  final File m_pdf2htmlEX_dataDir;
  final File m_poppler_dataDir;
  final File m_pdf2htmlEX_tmpDir;
  final File m_outputHtmlsDir;
  File p_inputPDF;

  private String p_ownerPassword = "";
  private String p_userPassword = "";
  private boolean p_outline = true;
  private boolean p_drm = true;
  private boolean p_embedFont = true;
  private boolean p_embedExternalFont = true;
  private String p_backgroundFormat = "";

  boolean p_wasPasswordEntered = false;

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

  public pdf2htmlEX(@NonNull Context ctx) {
    this(ctx, null);

    System.loadLibrary("pdf2htmlEX-android");

    for (Map.Entry<String, String> e : m_environment.entrySet()) {
      set_environment_value(e.getKey(), e.getValue());
    }
  }

  pdf2htmlEX(@NonNull Context ctx, @Nullable Object nullObjectToHaveDifferentCtor) {
    AssetExtractor ae = new AssetExtractor(ctx.getAssets()).setNoOverwrite();

    File filesDir = new File(ctx.getFilesDir(), "pdf2htmlEX");
    File cacheDir = new File(ctx.getCacheDir(), "pdf2htmlEX");

    // tmpDir is where pdf2htmlEX (not pdf2htmlEX-Android wrapper) does it's work
    m_pdf2htmlEX_tmpDir = new File(cacheDir, "pdf2htmlEX-tmp");
    m_outputHtmlsDir = new File(cacheDir, "output-htmls");

    File fontforgeHome = new File(cacheDir, "FontforgeHome");
    m_environment.put("HOME", fontforgeHome.getAbsolutePath());

    File envTMPDIR = new File(cacheDir, "envTMPDIR");
    m_environment.put("TMPDIR", envTMPDIR.getAbsolutePath());

    m_environment.put("USER", android.os.Build.MODEL);

    synchronized (s_initSynchronizer) {
      LegacyCleanup.cleanup(ctx);

      cacheDir.mkdir();

      // @TODO: https://github.com/ViliusSutkus89/pdf2htmlEX-Android/issues/9
      // pdf2htmlEX_dataDir is where pdf2htmlEX's share folder contents are
      m_pdf2htmlEX_dataDir = ae.extract(new File(filesDir, "share"), "pdf2htmlEX/share/pdf2htmlEX");

      // @TODO: https://github.com/ViliusSutkus89/pdf2htmlEX-Android/issues/10
      // Poppler requires encoding data
      m_poppler_dataDir = ae.extract(new File(filesDir, "share"), "pdf2htmlEX/share/poppler");

      m_pdf2htmlEX_tmpDir.mkdir();
      m_outputHtmlsDir.mkdir();

      fontforgeHome.mkdir();
      envTMPDIR.mkdir();

      FontconfigAndroid.init(ctx.getAssets(), cacheDir, filesDir, m_environment);
    }
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
    this.p_wasPasswordEntered = !ownerPassword.isEmpty() | !this.p_userPassword.isEmpty();
    return this;
  }

  public pdf2htmlEX setUserPassword(@NonNull String userPassword) {
    this.p_userPassword = userPassword;
    this.p_wasPasswordEntered = !this.p_ownerPassword.isEmpty() | !userPassword.isEmpty();
    return this;
  }

  public pdf2htmlEX setOutline(boolean enableOutline) {
    this.p_outline = enableOutline;
    return this;
  }

  public pdf2htmlEX setDRM(boolean enableDRM) {
    this.p_drm = enableDRM;
    return this;
  }

  public pdf2htmlEX setEmbedFont(boolean embedFont) {
    this.p_embedFont = embedFont;
    return this;
  }

  public pdf2htmlEX setEmbedExternalFont(boolean embedExternalFont) {
    this.p_embedExternalFont = embedExternalFont;
    return this;
  }

  /**
   * @param backgroundFormat: png (default), jpg or svg
   */
  public pdf2htmlEX setBackgroundFormat(@NonNull String backgroundFormat) {
    this.p_backgroundFormat = backgroundFormat;
    return this;
  }

  /*
   * @deprecated pdf2htmlEX-Android doesn't fork anymore
   */
  @Deprecated
  public void setNoForking(boolean thisArgumentIsIgnored) {
  }

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

    int retVal = convert_MakeTheActualCall(outputHtml);

    if (0 == retVal) {
      return outputHtml;
    }

    outputHtml.delete();

    // retVal values defined in pdf2htmlEX.cc
    switch (retVal) {
      case 2:
        if (!this.p_wasPasswordEntered) {
          throw new PasswordRequiredException("Password is required to decrypt this encrypted document!");
        } else {
          throw new WrongPasswordException("Wrong password is supplied to decrypt this encrypted document!");
        }

      case 3:
        throw new CopyProtectionException("Document is copy protected!");

      default:
        throw new ConversionFailedException("Return value from pdf2htmlEX: " + retVal);
    }
  }

  int convert_MakeTheActualCall(File outputHtml) throws IOException {
    return call_pdf2htmlEX(m_pdf2htmlEX_dataDir.getAbsolutePath(),
        m_poppler_dataDir.getAbsolutePath(), m_pdf2htmlEX_tmpDir.getAbsolutePath(),
        this.p_inputPDF.getAbsolutePath(), outputHtml.getAbsolutePath(),
        this.p_ownerPassword, this.p_userPassword, this.p_outline, this.p_drm,
        this.p_backgroundFormat, this.p_embedFont, this.p_embedExternalFont
    );
  }

  private native int call_pdf2htmlEX(String dataDir, String popplerDir, String tmpDir, String inputFile, String outputFile, String ownerPassword, String userPassword, boolean outline, boolean drm, String backgroundFormat, boolean embedFont, boolean embedExternalFont);

  // Because Java cannot setenv for the current process
  private static native void set_environment_value(String key, String value);
}
