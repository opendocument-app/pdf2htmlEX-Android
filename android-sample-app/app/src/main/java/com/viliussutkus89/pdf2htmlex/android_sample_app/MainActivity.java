package com.viliussutkus89.pdf2htmlex.android_sample_app;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.content.FileProvider;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.provider.LiveFolders;
import android.provider.OpenableColumns;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.Toast;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

public class MainActivity extends AppCompatActivity {

    // Used to load the 'native-lib' library on application startup.
    static {
        System.loadLibrary("native-lib");
    }

    static final String TAG = "ASM";

    static final int INTENT_OPEN = 1;
    static final int INTENT_SAVE = 2;
    static final int INTENT_SAVE_RESULT_FILENAME = 3;

    // DataDir is where pdf2htmlEX's share folder contents are
    private File m_pdf2htmlEX_dataDir;
    // tmpDir is where pdf2htmlEX does it's work
    private File m_pdf2htmlEX_tmpDir;
    // cacheDir is where this Android App stores incoming .pdf
    private File m_cacheDir;
    // outputDir is where produced .html's will be stored
    private File m_outputDir;

    private File m_convertedHTMLWaitingToBeSaved = null;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        m_pdf2htmlEX_dataDir = new File(getFilesDir(), "pdf2htmlEX");
        if (!m_pdf2htmlEX_dataDir.exists()) {
            ExtractAssets(getFilesDir(), "pdf2htmlEX");
        }
        m_pdf2htmlEX_tmpDir = new File(getCacheDir(), "pdf2htmlEX-tmp");
        m_cacheDir = new File(getCacheDir(), "incoming-pdf");

        // Must be defined in provider_paths.xml
        m_outputDir = new File(getCacheDir(), "produced-htmls");

        if (!m_pdf2htmlEX_tmpDir.exists()) {
            m_pdf2htmlEX_tmpDir.mkdir();
        }
        if (!m_cacheDir.exists()) {
            m_cacheDir.mkdir();
        }
        if (!m_outputDir.exists()) {
            m_outputDir.mkdir();
        }
    }

    // ExtractAssets adapted from
    // https://gist.github.com/tylerchesley/6198074
    private Boolean ExtractAssets(File output_dir, String name) {
        File output_name = new File(output_dir, name);
        try {
            String[] assets = getAssets().list(name);
            if (0 == assets.length) { // Processing a file
                InputStream in = getAssets().open(name);
                OutputStream out = new FileOutputStream(output_name);
                if (!copyFile(in, out)) {
                    return false;
                }
            } else { // Processing a folder
                if (!output_name.exists() && !output_name.mkdir()) {
                    return false;
                }
                for (String asset: assets) {
                    if (!ExtractAssets(output_dir, name + File.separator + asset)) {
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

    // https://stackoverflow.com/questions/5568874/how-to-extract-the-file-name-from-uri-returned-from-intent-action-get-content
    private String getFileName(Uri uri) {
        String result = null;
        if (uri.getScheme().equals("content")) {
            Cursor cursor = getContentResolver().query(uri, null, null, null, null);
            try {
                if (null != cursor && cursor.moveToFirst()) {
                    result = cursor.getString(cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME));
                }
            } finally {
                cursor.close();
            }
        }
        if (null == result) {
            result = uri.getPath();
            int cut = result.lastIndexOf('/');
            if (-1 != cut) {
                result = result.substring(cut + 1);
            }
        }
        return result;
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent resultData) {
        if (Activity.RESULT_OK != resultCode || null == resultData) {
            return;
        }
        if (INTENT_OPEN != requestCode && INTENT_SAVE != requestCode && INTENT_SAVE_RESULT_FILENAME != requestCode) {
            return;
        }

        /* Copy out the file to cache first.
            NDK side will have to open it and it won't go through the Android Content APIs...
            @TODO: Patch poppler to allow passing fileDescriptor instead of a filepath
         */
        Uri uri = resultData.getData();

        if (INTENT_SAVE_RESULT_FILENAME == requestCode) {
            try {
                if (null != m_convertedHTMLWaitingToBeSaved && m_convertedHTMLWaitingToBeSaved.exists()) {
                    InputStream input = new FileInputStream(m_convertedHTMLWaitingToBeSaved);
                    OutputStream output = getContentResolver().openOutputStream(uri);
                    if (!copyFile(input, output)) {
                        return;
                    }
                    m_convertedHTMLWaitingToBeSaved.delete();
                    m_convertedHTMLWaitingToBeSaved = null;
                    findViewById(R.id.button_save).setEnabled(true);
                }
            } catch (FileNotFoundException e) {
                return;
            }
            return;
        }

        String filename = getFileName(uri);
        File pdf_in_cache = new File(m_cacheDir, filename);
        try {
            InputStream input = getContentResolver().openInputStream(uri);
            OutputStream output = new FileOutputStream(pdf_in_cache);
            if (!copyFile(input, output)) {
                return;
            }
        } catch (FileNotFoundException e) {
            return;
        }

        File html = new File(m_outputDir, filename + ".html");

        // @TODO: should be in non-GUI thread
        if (0 != call_pdf2htmlEX(m_pdf2htmlEX_dataDir.toString(),
                m_pdf2htmlEX_tmpDir.toString(),
                pdf_in_cache.toString(),
                html.toString()) ){
            return;
        }

        pdf_in_cache.delete();

        if (html.exists()) {
            if (INTENT_OPEN == requestCode) {
                findViewById(R.id.button_open).setEnabled(true);

                Context ctx = getApplicationContext();
                String authority = ctx.getPackageName() + ".provider";
                Uri apkUri = FileProvider.getUriForFile(ctx, authority, html);
                Intent intent = new Intent(Intent.ACTION_VIEW);
                intent.addCategory(Intent.CATEGORY_BROWSABLE);
                intent.setDataAndType(apkUri, "text/html");
                intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
                startActivity(intent);
            }
            else if (INTENT_SAVE == requestCode) {
                // @TODO: could this variable be somehow passed through intent?
                m_convertedHTMLWaitingToBeSaved = html;

                Intent intent = new Intent(Intent.ACTION_CREATE_DOCUMENT);
                intent.setType("text/html");
                intent.putExtra(Intent.EXTRA_TITLE, filename + ".html");
                startActivityForResult(intent, INTENT_SAVE_RESULT_FILENAME);
            }
        }
    }

    public void handleOpenButton(View v) {
        v.setEnabled(false);
        Intent openPDFIntent = new Intent(Intent.ACTION_GET_CONTENT);
        openPDFIntent.addCategory(Intent.CATEGORY_OPENABLE);
        openPDFIntent.setType("application/pdf");
        startActivityForResult(openPDFIntent, INTENT_OPEN);
    }

    public void handleSaveButton(View v) {
        v.setEnabled(false);
        Intent openPDFIntent = new Intent(Intent.ACTION_GET_CONTENT);
        openPDFIntent.addCategory(Intent.CATEGORY_OPENABLE);
        openPDFIntent.setType("application/pdf");
        startActivityForResult(openPDFIntent, INTENT_SAVE);
    }

    public native int call_pdf2htmlEX(String dataDir, String tmpDir, String inputFile, String outputFile);
}
