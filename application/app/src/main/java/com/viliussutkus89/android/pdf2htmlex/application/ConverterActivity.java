package com.viliussutkus89.android.pdf2htmlex.application;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.view.MenuItem;
import android.view.View;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.appcompat.app.ActionBar;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;
import androidx.core.app.NavUtils;
import androidx.core.content.FileProvider;
import androidx.lifecycle.Observer;
import androidx.work.Data;
import androidx.work.OneTimeWorkRequest;
import androidx.work.WorkInfo;
import androidx.work.WorkManager;
import androidx.work.WorkRequest;

import java.io.File;
import java.util.UUID;

public class ConverterActivity extends AppCompatActivity {
    private static final String BUNDLE_KEY__WORK_REQUEST_ID = "work request id";
    private UUID m_workRequestId;
    private String m_inputFilename;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_converter);

        Toolbar toolbar = findViewById(R.id.toolbar_converter);
        setSupportActionBar(toolbar);
        ActionBar actionBar = getSupportActionBar();
        if (actionBar != null) {
            actionBar.setDisplayHomeAsUpEnabled(true);
            actionBar.setDisplayShowHomeEnabled(true);
        }

        final TextView statusText = findViewById(R.id.status_text);

        // @TODO: implying getIntent() is same when recreating Activity
        Intent intent = getIntent();
        String action = intent.getAction();

        final Uri inputUri;
        // ACTION_VIEW and Intent from MainActivity sends URI in data field
        if (null == action || Intent.ACTION_VIEW.equals(action)) {
            inputUri = intent.getData();
        }
        // ACTION_SEND sends URI in extra
        else if (Intent.ACTION_SEND.equals(action)) {
            inputUri = intent.getParcelableExtra(Intent.EXTRA_STREAM);
        }
        else {
            statusText.setText(R.string.conversion_status_error);
            findViewById(R.id.progress_bar).setVisibility(View.GONE);
            findViewById(R.id.button_cancel).setVisibility(View.GONE);
            return;
        }

        m_inputFilename = GetFileName.FromUri(getContentResolver(), inputUri);
        toolbar.setSubtitle(m_inputFilename);

        // Must be defined in provider_paths.xml
        File outputDir = new File(getCacheDir(), "produced-HTMLs");

        m_workRequestId = null;
        if (null != savedInstanceState) {
            m_workRequestId = UUID.fromString(savedInstanceState.getString(BUNDLE_KEY__WORK_REQUEST_ID, null));
        }
        final WorkManager workManager = WorkManager.getInstance(getApplicationContext());
        if (null == m_workRequestId) {
            WorkRequest converterWork = new OneTimeWorkRequest.Builder(ConverterWorker.class)
                    .setInputData(new Data.Builder()
                        .putString(ConverterWorker.INPUT__URI, inputUri.toString())
                        .putString(ConverterWorker.INPUT__DESTINATION_DIR, outputDir.getAbsolutePath())
                        .build())
                    .build();
            workManager.enqueue(converterWork);
            m_workRequestId = converterWork.getId();
        }

        workManager.getWorkInfoByIdLiveData(m_workRequestId).observe(this, m_updateObserver);

        findViewById(R.id.button_cancel).setOnClickListener(view -> {
            WorkManager.getInstance(getApplicationContext()).cancelWorkById(m_workRequestId);
            NavUtils.navigateUpFromSameTask(this);
        });
    }

    private final Observer<WorkInfo> m_updateObserver = workInfo -> {
        if (null == workInfo) {
            return;
        }

        final TextView statusText = findViewById(R.id.status_text);
        switch (workInfo.getState()) {
            case RUNNING:
            case ENQUEUED:
            case BLOCKED:
                switch (ConverterWorker.getProgress(workInfo)) {
                    case INIT:
                    case COPYING_INPUT:
                        statusText.setText(R.string.conversion_status_input);
                        break;
                    case CONVERTING:
                        statusText.setText(R.string.conversion_status_work);
                        break;
                }
                break;

            case SUCCEEDED:
                final String outputFileString = workInfo.getOutputData().getString(ConverterWorker.OUTPUT__URI);
                if (null != outputFileString) {
                    Uri convertedUri = FileProvider.getUriForFile(this, getPackageName() + ".provider", new File(outputFileString));
                    Intent readerIntent = new Intent(this, HTMLReaderActivity.class);
                    readerIntent.setData(convertedUri);
                    readerIntent.putExtra(HTMLReaderActivity.INTENT_EXTRA_INPUT__FILENAME, m_inputFilename);
                    readerIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_TASK_ON_HOME);
                    startActivity(readerIntent);
                    break;
                }
                // Intentional case fall through without "break"
            case FAILED:
                statusText.setText(R.string.conversion_status_error);
                findViewById(R.id.progress_bar).setVisibility(View.GONE);
                findViewById(R.id.button_cancel).setVisibility(View.GONE);
                break;
        }
    };

    @Override
    protected void onSaveInstanceState(@NonNull Bundle outState) {
        super.onSaveInstanceState(outState);
        if (null != m_workRequestId) {
            outState.putString(BUNDLE_KEY__WORK_REQUEST_ID, m_workRequestId.toString());
        }
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        if (android.R.id.home == item.getItemId()) {
            WorkManager.getInstance(this).cancelWorkById(m_workRequestId);
        }
        return super.onOptionsItemSelected(item);
    }
}
