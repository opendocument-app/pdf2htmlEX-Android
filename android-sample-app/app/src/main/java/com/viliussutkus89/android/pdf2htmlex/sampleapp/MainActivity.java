package com.viliussutkus89.android.pdf2htmlex.sampleapp;

import android.content.ActivityNotFoundException;
import android.content.ContentResolver;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.provider.OpenableColumns;
import android.widget.Toast;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.content.FileProvider;

import com.google.android.gms.oss.licenses.OssLicensesMenuActivity;
import com.viliussutkus89.android.pdf2htmlex.pdf2htmlEX;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

public class MainActivity extends AppCompatActivity {
    // cacheDir is where this Android App stores incoming .pdf
    private File m_inputDir;
    // outputDir is where produced .html's will be stored
    private File m_outputDir;

    private File m_convertedHTMLWaitingToBeSaved = null;

    private final ActivityResultLauncher<String> m_openPdfForReading = registerForActivityResult(new ActivityResultContracts.GetContent(),
            selectedInputDocument -> {
                Context ctx = getApplicationContext();
                File html;
                try {
                    html = convertPdfToHTML(ctx, selectedInputDocument);
                } catch (IOException | pdf2htmlEX.ConversionFailedException e) {
                    Toast.makeText(ctx, "Conversion failed!", Toast.LENGTH_LONG).show();
                    return;
                }

                File htmlInOutputFolder = new File(m_outputDir, html.getName());
                html.renameTo(htmlInOutputFolder);

                String authority = ctx.getPackageName() + ".provider";
                Uri apkUri = FileProvider.getUriForFile(ctx, authority, htmlInOutputFolder);
                Intent intent = new Intent(Intent.ACTION_VIEW);
                intent.addCategory(Intent.CATEGORY_BROWSABLE);
                intent.setDataAndType(apkUri, "text/html");
                intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
                try {
                    startActivity(intent);
                } catch (ActivityNotFoundException e) {
                    Toast.makeText(ctx, "HTML document generated, but failed to open HTML reader!", Toast.LENGTH_LONG).show();
                }
            });

    private final ActivityResultLauncher<String> m_saveHTML = registerForActivityResult(new ActivityResultContracts.CreateDocument(),
            selectedOutputDocument -> {
                try {
                    InputStream input = new FileInputStream(m_convertedHTMLWaitingToBeSaved);
                    OutputStream output = getContentResolver().openOutputStream(selectedOutputDocument);
                    copyFile(input, output);
                    m_convertedHTMLWaitingToBeSaved.delete();
                } catch (IOException e) {
                    Toast.makeText(getApplicationContext(), "Failed to save HTML document!", Toast.LENGTH_LONG).show();
                }
                m_convertedHTMLWaitingToBeSaved = null;
            });

    private final ActivityResultLauncher<String> m_openPdfForSaving = registerForActivityResult(new ActivityResultContracts.GetContent(),
            selectedInputDocument -> {
                Context ctx = getApplicationContext();
                File html;
                try {
                    html = convertPdfToHTML(ctx, selectedInputDocument);
                } catch (IOException | pdf2htmlEX.ConversionFailedException e) {
                    Toast.makeText(ctx, "Conversion failed!", Toast.LENGTH_LONG).show();
                    return;
                }
                m_convertedHTMLWaitingToBeSaved = html;
                m_saveHTML.launch(m_convertedHTMLWaitingToBeSaved.getName());
            });

    // @TODO: should be in non-GUI thread
    private File convertPdfToHTML(Context ctx, Uri input) throws IOException, pdf2htmlEX.ConversionFailedException {
        String filename = getFileName(ctx.getContentResolver(), input);
        File pdf_in_cache = new File(m_inputDir, filename);

        InputStream inputStream = getContentResolver().openInputStream(input);
        OutputStream outputStream = new FileOutputStream(pdf_in_cache);
        copyFile(inputStream, outputStream);

        pdf2htmlEX converter = new pdf2htmlEX(ctx);
        converter.setInputPDF(pdf_in_cache);
        File html = converter.convert();
        pdf_in_cache.delete();
        return html;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        m_inputDir = new File(getCacheDir(), "incoming-pdf");
        m_inputDir.mkdir();

        // Must be defined in provider_paths.xml
        m_outputDir = new File(getCacheDir(), "produced-htmls");
        m_outputDir.mkdir();

        findViewById(R.id.button_open).setOnClickListener(view -> m_openPdfForReading.launch("application/pdf"));
        findViewById(R.id.button_save).setOnClickListener(view -> m_openPdfForSaving.launch("application/pdf"));
        findViewById(R.id.button_licenses).setOnClickListener(view -> startActivity(new Intent(this, OssLicensesMenuActivity.class)));
    }

    private void copyFile(InputStream input, OutputStream output) throws IOException {
        final int buffer_size = 1024;
        byte[] buffer = new byte[buffer_size];

        try (BufferedInputStream in = new BufferedInputStream(input, buffer_size)) {
            try (BufferedOutputStream out = new BufferedOutputStream(output, buffer_size)) {
                int read;
                while (-1 != (read = in.read(buffer))) {
                    out.write(buffer, 0, read);
                }
                out.flush();
            } finally {
                output.close();
            }
        } finally {
            input.close();
        }
    }

    // https://developer.android.com/training/secure-file-sharing/retrieve-info
    private String getFileName(ContentResolver contentResolver, Uri uri) {
        try (Cursor cursor = contentResolver.query(uri, null, null, null, null)) {
            cursor.moveToFirst();
            int nameIndex = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME);
            if (nameIndex < 0) {
                // This should not happen, but checking anyway to make the lint happy.
                return "UnknownFile";
            }
            return cursor.getString(nameIndex);
        }
    }
}
