package com.viliussutkus89.android.pdf2htmlex.sampleapp;

import android.annotation.SuppressLint;
import android.net.Uri;
import android.os.Bundle;
import android.webkit.WebSettings;
import android.webkit.WebView;

import androidx.annotation.NonNull;
import androidx.appcompat.app.ActionBar;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;

public class HTMLReaderActivity extends AppCompatActivity {
    static final String INTENT_EXTRA_INPUT__FILENAME = "input.filename.pdf";
    private static final String BUNDLE_KEY__WEB_VIEW = "m_webView.state";

    private WebView m_webView = null;

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

        try {
            Bundle wvBundle = savedInstanceState.getBundle(BUNDLE_KEY__WEB_VIEW);
            m_webView.restoreState(wvBundle);
        } catch (NullPointerException ignored) {
            Uri convertedResult = getIntent().getData();
            m_webView.loadUrl(convertedResult.toString());
        }
    }

    @Override
    protected void onSaveInstanceState(@NonNull Bundle outState) {
        super.onSaveInstanceState(outState);

        Bundle wwBundle = new Bundle();
        m_webView.saveState(wwBundle);
        outState.putBundle(BUNDLE_KEY__WEB_VIEW, wwBundle);
    }
}
