package com.viliussutkus89.android.pdf2htmlex.sampleapp;

import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.appcompat.app.AppCompatActivity;

public class MainActivity extends AppCompatActivity {

    private final ActivityResultLauncher<String> m_openDocument = registerForActivityResult(
            new ActivityResultContracts.GetContent(),
            selectedInputDocument -> {
                if (null != selectedInputDocument) {
                    final Intent converterIntent = new Intent(this, ConverterActivity.class);
                    converterIntent.setData(selectedInputDocument);
                    startActivity(converterIntent);
                }
            });

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        setSupportActionBar(findViewById(R.id.toolbar_main));

        Button buttonOpen = findViewById(R.id.button_open);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            buttonOpen.setOnClickListener(view -> m_openDocument.launch("application/pdf"));
        } else {
            buttonOpen.setEnabled(false);
            findViewById(R.id.text_button_open_pdf_disabled).setVisibility(View.VISIBLE);
        }
        findViewById(R.id.button_about).setOnClickListener(view -> startActivity(new Intent(this, AboutActivity.class)));
    }
}
