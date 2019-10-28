package com.viliussutkus89.pdf2htmlex_sample;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.provider.OpenableColumns;
import android.util.Log;
import android.view.View;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.content.FileProvider;

import com.google.android.gms.oss.licenses.OssLicensesMenuActivity;
import com.viliussutkus89.android.pdf2htmlex.pdf2htmlEX;

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

    static final String TAG = "P2H";

    static final int INTENT_OPEN = 1;
    static final int INTENT_SAVE = 2;
    static final int INTENT_SAVE_RESULT_FILENAME = 3;

    // cacheDir is where this Android App stores incoming .pdf
    private File m_inputDir;
    // outputDir is where produced .html's will be stored
    private File m_outputDir;

    private File m_convertedHTMLWaitingToBeSaved = null;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        m_inputDir = new File(getCacheDir(), "incoming-pdf");
        m_inputDir.mkdir();

        // Must be defined in provider_paths.xml
        m_outputDir = new File(getCacheDir(), "produced-htmls");
        m_outputDir.mkdir();
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
        super.onActivityResult(requestCode, resultCode, resultData);

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
        File pdf_in_cache = new File(m_inputDir, filename);
        try {
            InputStream input = getContentResolver().openInputStream(uri);
            OutputStream output = new FileOutputStream(pdf_in_cache);
            if (!copyFile(input, output)) {
                return;
            }
        } catch (FileNotFoundException e) {
            return;
        }

        Context ctx = getApplicationContext();
        pdf2htmlEX converter = new pdf2htmlEX(ctx);

        File html;
        try {
            // @TODO: should be in non-GUI thread
            html = converter.convert(pdf_in_cache);
        } catch (Exception e) {
            Toast.makeText(ctx, "Conversion failed: " + e.getMessage(), Toast.LENGTH_LONG).show();
            pdf_in_cache.delete();
            return;
        }

        pdf_in_cache.delete();

        if (html.exists()) {
            if (INTENT_OPEN == requestCode) {
                File htmlInOutputFolder = new File(m_outputDir, html.getName());
                html.renameTo(htmlInOutputFolder);

                findViewById(R.id.button_open).setEnabled(true);

                String authority = ctx.getPackageName() + ".provider";
                Uri apkUri = FileProvider.getUriForFile(ctx, authority, htmlInOutputFolder);
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

    public void handleShowLicenses(View v) {
        startActivity(new Intent(this, OssLicensesMenuActivity.class));
    }
}
