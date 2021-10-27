package com.viliussutkus89.android.pdf2htmlex.application;

import android.annotation.SuppressLint;
import android.content.ActivityNotFoundException;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.widget.Toast;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.NonNull;
import androidx.appcompat.app.ActionBar;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;
import androidx.work.Data;
import androidx.work.OneTimeWorkRequest;
import androidx.work.WorkManager;
import androidx.work.WorkRequest;

public class HTMLReaderActivity extends AppCompatActivity {
    static final String INTENT_EXTRA_INPUT__FILENAME = "input.filename.pdf";
    private static final String BUNDLE_KEY__WEB_VIEW = "m_webView.state";

    private WebView m_webView = null;

    private ActivityResultLauncher<String> m_saveDocument;

    @SuppressLint("SetJavaScriptEnabled")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_html_reader);

        Toolbar toolbar = findViewById(R.id.toolbar_reader);
        setSupportActionBar(toolbar);
        ActionBar actionBar = getSupportActionBar();
        if (actionBar != null) {
            actionBar.setDisplayHomeAsUpEnabled(true);
            actionBar.setDisplayShowHomeEnabled(true);
        }
        toolbar.setSubtitle(getIntent().getStringExtra(INTENT_EXTRA_INPUT__FILENAME));

        m_webView = findViewById(R.id.web_view);

        final WebSettings ws = m_webView.getSettings();
        ws.setSupportZoom(true);
        ws.setBuiltInZoomControls(true);
        ws.setDisplayZoomControls(true);
        ws.setJavaScriptEnabled(true);
        ws.setAllowContentAccess(true);

        ws.setAllowFileAccess(false);
        ws.setBlockNetworkLoads(true);

        final Uri convertedDocument = getIntent().getData();
        try {
            Bundle wvBundle = savedInstanceState.getBundle(BUNDLE_KEY__WEB_VIEW);
            m_webView.restoreState(wvBundle);
        } catch (NullPointerException ignored) {
            m_webView.loadUrl(convertedDocument.toString());
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            m_saveDocument = registerForActivityResult(new ActivityResultContracts.CreateDocument(),
                    selectedOutputDocument -> {
                        if (null == selectedOutputDocument) {
                            return;
                        }
                        WorkRequest saveWork = new OneTimeWorkRequest.Builder(SaveWorker.class)
                                .setInputData(new Data.Builder()
                                        .putString(SaveWorker.INPUT__INPUT_URI, convertedDocument.toString())
                                        .putString(SaveWorker.INPUT__OUTPUT_URI, selectedOutputDocument.toString())
                                        .build())
                                .build();
                        WorkManager workManager = WorkManager.getInstance(getApplicationContext());
                        workManager.enqueue(saveWork);
                        workManager.getWorkInfoByIdLiveData(saveWork.getId()).observe(this, workInfo -> {
                            if (null == workInfo) {
                                return;
                            }
                            switch (workInfo.getState()) {
                                case SUCCEEDED:
                                    Toast.makeText(getApplicationContext(), R.string.save_successful, Toast.LENGTH_LONG).show();
                                    break;
                                case FAILED:
                                    Toast.makeText(getApplicationContext(), R.string.error_save_failed, Toast.LENGTH_LONG).show();
                                    break;
                            }
                        });
                    });
        }
    }

    @Override
    protected void onSaveInstanceState(@NonNull Bundle outState) {
        super.onSaveInstanceState(outState);

        Bundle wwBundle = new Bundle();
        m_webView.saveState(wwBundle);
        outState.putBundle(BUNDLE_KEY__WEB_VIEW, wwBundle);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.html_reader_menu, menu);
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.KITKAT) {
            menu.findItem(R.id.action_save).setEnabled(false);
        }
        return super.onCreateOptionsMenu(menu);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        if (R.id.action_share == item.getItemId()) {
            Intent shareIntent = new Intent(Intent.ACTION_SEND);
            shareIntent.setType("text/html");
            shareIntent.putExtra(Intent.EXTRA_STREAM, getIntent().getData());
            shareIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
            try {
                startActivity(shareIntent);
            } catch (ActivityNotFoundException e) {
                Toast.makeText(this, R.string.error_share_failed, Toast.LENGTH_LONG).show();
            }
            return true;
        }

        if (R.id.action_save == item.getItemId()) {
            String filename = GetFileName.FromUri(getContentResolver(), getIntent().getData());
            m_saveDocument.launch(filename);
            return true;
        }

        return super.onOptionsItemSelected(item);
    }
}
