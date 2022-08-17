/*
 * pdf2htmlEX.java
 *
 * Copyright (C) 2019, 2020, 2022 ViliusSutkus89.com
 *
 * pdf2htmlEX-Android is free software: you can redistribute it and/or modify
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

import com.getkeepsafe.relinker.ReLinker;
import com.getkeepsafe.relinker.ReLinkerInstance;
import com.viliussutkus89.android.assetextractor.AssetExtractor;
import com.viliussutkus89.android.tmpfile.Tmpfile;

import java.io.Closeable;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;


public class pdf2htmlEX implements Closeable {
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

  private final NativeConverter nc;

  static private final Object s_initSynchronizer = new Object();

  private final File m_outputHtmlsDir;

  private File mInputPdf;
  private File mOutputHtml;
  private boolean mUserPasswordEntered;
  private boolean mOwnerPasswordEntered;

  public pdf2htmlEX(@NonNull Context ctx) {
    ReLinkerInstance reLinker = ReLinker.recursively();

    // https://github.com/KeepSafe/ReLinker/issues/77
    // Manually load dependencies, because ReLinker.recursively() doesn't actually load recursively
    reLinker.loadLibrary(ctx, "c++_shared");
    reLinker.loadLibrary(ctx, "envvar");
    reLinker.loadLibrary(ctx, "tmpfile");
    reLinker.loadLibrary(ctx, "pdf2htmlEX-android");

    AssetExtractor ae = new AssetExtractor(ctx.getAssets()).setNoOverwrite();

    File filesDir = new File(ctx.getFilesDir(), "pdf2htmlEX");
    File cacheDir = new File(ctx.getCacheDir(), "pdf2htmlEX");

    // tmpDir is where pdf2htmlEX (not pdf2htmlEX-Android wrapper) does it's work
    File pdf2htmlEX_tmpDir = new File(cacheDir, "pdf2htmlEX-tmp");
    m_outputHtmlsDir = new File(cacheDir, "output-htmls");

    File fontforgeHome = new File(cacheDir, "FontforgeHome");
    File envTMPDIR = new File(cacheDir, "envTMPDIR");

    synchronized (s_initSynchronizer) {
      LegacyCleanup.cleanup(ctx);

      cacheDir.mkdir();

      // @TODO: https://github.com/ViliusSutkus89/pdf2htmlEX-Android/issues/9
      // pdf2htmlEX_dataDir is where pdf2htmlEX's share folder contents are
      File pdf2htmlEX_dataDir = ae.extract(new File(filesDir, "share"), "pdf2htmlEX/share/pdf2htmlEX");

      // @TODO: https://github.com/ViliusSutkus89/pdf2htmlEX-Android/issues/10
      // Poppler requires encoding data
      File poppler_dataDir = ae.extract(new File(filesDir, "share"), "pdf2htmlEX/share/poppler");

      pdf2htmlEX_tmpDir.mkdir();
      m_outputHtmlsDir.mkdir();

      fontforgeHome.mkdir();
      EnvVar.set("HOME", fontforgeHome.getAbsolutePath());

      envTMPDIR.mkdir();
      EnvVar.set("TMPDIR", envTMPDIR.getAbsolutePath());

      FontconfigAndroid.init(ctx.getAssets(), cacheDir, filesDir);

      EnvVar.set("USER", android.os.Build.MODEL);

      nc = new NativeConverter(pdf2htmlEX_tmpDir, pdf2htmlEX_dataDir, poppler_dataDir);
    }

    Tmpfile.init(ctx.getCacheDir());
  }

  @Override
  public void close() {
    nc.close();
  }

  public static String generateOutputFilename(String inputFilename) {
    String inputFilenameNoPDFExt = inputFilename;
    if (inputFilenameNoPDFExt.endsWith(".pdf")) {
      inputFilenameNoPDFExt = inputFilenameNoPDFExt.substring(0, inputFilenameNoPDFExt.length() - 4);
    }
    return inputFilenameNoPDFExt + ".html";
  }

  private static File generateOutputFile(File outputDir, String inputFilename) throws IOException {
    String outputFilenameNoExt = generateOutputFilename(inputFilename);
    outputFilenameNoExt = outputFilenameNoExt.substring(0, outputFilenameNoExt.length() - 5);

    File outputFile = new File(outputDir, outputFilenameNoExt + ".html");
    for (int i = 0; !outputFile.createNewFile(); i++) {
      outputFile = new File(outputDir, outputFilenameNoExt + "-" + i + ".html");
    }

    return outputFile;
  }

  public File convert() throws IOException, ConversionFailedException {
    File inputPdf = mInputPdf;
    if (null == inputPdf) {
      throw new ConversionFailedException("No Input PDF given!");
    } else if (!inputPdf.exists()) {
      throw new FileNotFoundException();
    }
    NativeConverter.setInputFile(nc.mConverter, inputPdf.getAbsolutePath());

    File outputHtml = mOutputHtml;
    if (null == outputHtml) {
      outputHtml = generateOutputFile(m_outputHtmlsDir, inputPdf.getName());
    }
    NativeConverter.setOutputFile(nc.mConverter, outputHtml.getAbsolutePath());

    int retVal = NativeConverter.convert(nc.mConverter);
    if (0 == retVal) {
      return outputHtml;
    }

    outputHtml.delete();

    // retVal values defined in pdf2htmlEX.cc
    switch (retVal) {
      case 2:
        if (!mUserPasswordEntered && !mOwnerPasswordEntered) {
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

  public File convert(@NonNull File inputPDF) throws IOException, ConversionFailedException {
    setInputPDF(inputPDF);
    return convert();
  }

  public pdf2htmlEX setInputPDF(@Nullable File inputPDF) {
    mInputPdf = inputPDF;
    return this;
  }

  public pdf2htmlEX setOutputHtml(@Nullable File outputHtml) {
    mOutputHtml = outputHtml;
    return this;
  }

  public pdf2htmlEX setOwnerPassword(@Nullable String ownerPassword) {
    NativeConverter.setOwnerPassword(nc.mConverter, ownerPassword);
    mOwnerPasswordEntered = ownerPassword != null && !ownerPassword.isEmpty();
    return this;
  }

  public pdf2htmlEX setUserPassword(@Nullable String userPassword) {
    NativeConverter.setUserPassword(nc.mConverter, userPassword);
    mUserPasswordEntered = userPassword != null && !userPassword.isEmpty();
    return this;
  }

  public pdf2htmlEX setOutline(boolean enableOutline) {
    NativeConverter.setOutline(nc.mConverter, enableOutline);
    return this;
  }

  public pdf2htmlEX setDRM(boolean enableDrm) {
    NativeConverter.setDrm(nc.mConverter, enableDrm);
    return this;
  }

  public pdf2htmlEX setEmbedFont(boolean embedFont) {
    NativeConverter.setEmbedFont(nc.mConverter, embedFont);
    return this;
  }

  public pdf2htmlEX setEmbedExternalFont(boolean embedExternalFont) {
    NativeConverter.setEmbedExternalFont(nc.mConverter, embedExternalFont);
    return this;
  }

  public pdf2htmlEX setProcessAnnotation(boolean processAnnotation) {
    NativeConverter.setProcessAnnotation(nc.mConverter, processAnnotation);
    return this;
  }

  /**
   * @param backgroundFormat: png (default), jpg or svg
   */
  public pdf2htmlEX setBackgroundFormat(@NonNull String backgroundFormat) {
    NativeConverter.setBackgroundFormat(nc.mConverter, backgroundFormat);
    return this;
  }
}
