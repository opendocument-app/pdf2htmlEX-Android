package com.viliussutkus89.android.pdf2htmlex;

import android.content.res.AssetManager;

import androidx.annotation.NonNull;

import com.viliussutkus89.android.assetextractor.AssetExtractor;
import com.viliussutkus89.android.fontconfigtranslator.FontconfigTranslator;

import java.io.File;
import java.util.Map;

final class FontconfigAndroid {
    static void init(@NonNull AssetManager assetManager, @NonNull File cacheDir, @NonNull File filesDir, @NonNull Map<String, String> environment) {
        File xdgCache = new File(cacheDir, "xdg-cache");
        xdgCache.mkdir();
        environment.put("XDG_CACHE_HOME", xdgCache.getAbsolutePath());

        AssetExtractor ae = new AssetExtractor(assetManager).setNoOverwrite();
        File fontsConfigDir = ae.extract(new File(filesDir, "etc"), "pdf2htmlEX/etc/fonts");
        environment.put("FONTCONFIG_PATH", fontsConfigDir.getAbsolutePath());

        ae.extract(new File(filesDir, "share"), "pdf2htmlEX/share/fonts");

        File fontconfigGeneratedXml = new File(fontsConfigDir, "system-etc-fonts-xml-translated.conf");
        FontconfigTranslator.translate(fontconfigGeneratedXml);
    }
}
