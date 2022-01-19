/*
 * pdf2htmlEX_exe.java
 *
 * Copyright (C) 2020 - 2021 Vilius Sutkus'89
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

import com.viliussutkus89.android.executablerunner.ExecutableRunner;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.Map;

/*
 * @deprecated pdf2htmlEX_exe is experimental, expect changes.
 */
@Deprecated
public class pdf2htmlEX_exe extends pdf2htmlEX {

  /*
   * @deprecated m_arguments is exposed, but take caution not to mess it up too much.
   */
  @Deprecated
  protected final Map<String, String> m_arguments = new LinkedHashMap<>();

  private final File m_conversionLog = new File(m_pdf2htmlEX_tmpDir, "conversion.log");
  private final File m_executable;

  public pdf2htmlEX_exe(@NonNull Context ctx) {
    super(ctx, null);

    m_executable = new File(ctx.getApplicationInfo().nativeLibraryDir, "libpdf2htmlEX-exe_not_lib.so");
  }

  @Override
  int convert_MakeTheActualCall(File outputHtml) throws IOException {
    ArrayList<String> arguments = new ArrayList<>(Arrays.asList(
        "--data-dir",
        m_pdf2htmlEX_dataDir.getAbsolutePath(),

        "--tmp-dir",
        m_pdf2htmlEX_tmpDir.getAbsolutePath(),

        "--poppler-data-dir",
        m_poppler_dataDir.getAbsolutePath()
    ));
    arguments.ensureCapacity(arguments.size() +  this.m_arguments.size() * 2 + 2);

    for (Map.Entry<String, String> it : this.m_arguments.entrySet()) {
      arguments.add(it.getKey());
      String val = it.getValue();
      if (!val.isEmpty()) {
        arguments.add(val);
      }
    }

    arguments.add(this.p_inputPDF.getAbsolutePath());
    arguments.add(outputHtml.getName());

    FileOutputStream conversionStream = new FileOutputStream(this.m_conversionLog);

    ExecutableRunner runner = new ExecutableRunner(this.m_executable, this.m_outputHtmlsDir);
    runner.setStdout(conversionStream).setStderr(conversionStream);
    runner.addEnvironmentValues(this.m_environment);
    return runner.run(arguments);
  }

  @Override
  public pdf2htmlEX setOwnerPassword(@NonNull String ownerPassword) {
    if (!ownerPassword.isEmpty()){
      this.m_arguments.put("--owner-password", ownerPassword);
    } else {
      this.m_arguments.remove("--owner-password");
    }
    this.p_wasPasswordEntered = !ownerPassword.isEmpty() | this.m_arguments.containsKey("--user-password");
    return this;
  }

  @Override
  public pdf2htmlEX setUserPassword(@NonNull String userPassword) {
    if (!userPassword.isEmpty()){
      this.m_arguments.put("--user-password", userPassword);
    } else {
      this.m_arguments.remove("--user-password");
    }
    this.p_wasPasswordEntered = this.m_arguments.containsKey("--owner-password") | !userPassword.isEmpty();
    return this;
  }

  @Override
  public pdf2htmlEX setOutline(boolean enableOutline) {
    this.m_arguments.put("--process-outline", enableOutline ? "1" : "0");
    return this;
  }

  @Override
  public pdf2htmlEX setDRM(boolean enableDRM) {
    this.m_arguments.put("--no-drm", !enableDRM ? "1" : "0");
    return this;
  }

  @Override
  public pdf2htmlEX setEmbedFont(boolean embedFont) {
    this.m_arguments.put("--embed-font", embedFont ? "1" : "0");
    return this;
  }

  @Override
  public pdf2htmlEX setEmbedExternalFont(boolean embedExternalFont) {
    this.m_arguments.put("--embed-external-font", embedExternalFont ? "1" : "0");
    return this;
  }

  public pdf2htmlEX setProcessAnnotation(boolean processAnnotation) {
    this.m_arguments.put("--process-annotation", processAnnotation ? "1" : "0");
    return this;
  }

  /**
   * @param backgroundFormat: png (default), jpg or svg
   */
  @Override
  public pdf2htmlEX setBackgroundFormat(@NonNull String backgroundFormat) {
    this.m_arguments.put("--bg_format", backgroundFormat);
    return this;
  }

}
