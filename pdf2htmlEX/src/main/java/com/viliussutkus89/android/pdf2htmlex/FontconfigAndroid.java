package com.viliussutkus89.android.pdf2htmlex;

import android.content.res.AssetManager;
import android.util.Log;
import android.util.Xml;

import androidx.annotation.NonNull;

import org.xmlpull.v1.XmlPullParser;
import org.xmlpull.v1.XmlPullParserException;
import org.xmlpull.v1.XmlSerializer;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.Writer;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedList;
import java.util.List;

final class FontconfigAndroid {
    private static final String TAG = "FontconfigAndroid";

    // Available on API 21+
    private final static File configFile = new File("/system/etc/fonts.xml");

    // Available on API 16-20
    private final static File legacyConfigFile = new File("/system/etc/system_fonts.xml");

    static void init(@NonNull AssetManager assetManager, @NonNull File cacheDir, @NonNull File filesDir) {
        File xdgCache = new File(cacheDir, "xdg-cache");

        xdgCache.mkdir();
        pdf2htmlEX.set_environment_value("XDG_CACHE_HOME", xdgCache.getAbsolutePath());

        File fontsConfigDir = new File(filesDir, "etc/fonts");
        if (!fontsConfigDir.exists()) {
            AssetExtractor.extract(assetManager, filesDir, "etc/fonts");
        }
        AssetExtractor.extract(assetManager, filesDir, "fonts");
        pdf2htmlEX.set_environment_value("FONTCONFIG_PATH", fontsConfigDir.getAbsolutePath());

        boolean isLegacy = false;
        InputStream afx;
        try {
            afx = new FileInputStream(configFile);
        } catch (FileNotFoundException ignored) {
            isLegacy = true;
            try {
                afx = new FileInputStream(legacyConfigFile);
            } catch (FileNotFoundException ignored_) {
                Log.e(TAG, "No Android font config file found!");
                return;
            }
        }

        File fontconfigGeneratedXml = new File(fontsConfigDir, "system-etc-fonts-xml-translated.conf");
        if (fontconfigGeneratedXml.length() > 0) {
            // already generated
            return;
        }

        try {
            Writer output = new FileWriter(fontconfigGeneratedXml);

            XmlPullParser parser = Xml.newPullParser();
            parser.setFeature(XmlPullParser.FEATURE_PROCESS_NAMESPACES, false);
            parser.setInput(afx, null);
            parser.nextTag();
            parser.require(XmlPullParser.START_TAG, null, "familyset");

            XmlSerializer outputXML = Xml.newSerializer();
            outputXML.setOutput(output);
            outputXML.setFeature("http://xmlpull.org/v1/doc/features.html#indent-output", true);
            outputXML.startDocument(null, false);
            outputXML.startTag(null, "fontconfig");

            outputXML.startTag(null, "description");
            outputXML.text("Android font configuration, parsed from /system/etc/fonts.xml");
            outputXML.endTag(null, "description");

            List<FontFamily> fontFamilies = new ArrayList<>();
            while (XmlPullParser.END_TAG != parser.next()) {
                if (XmlPullParser.START_TAG != parser.getEventType()) {
                    continue;
                }
                switch (parser.getName()) {
                    case "alias":
                        new FontAlias(parser).write(outputXML);
                        break;
                    case "family":
                        if (isLegacy) {
                            new LegacyFontFamily(parser).write(outputXML);
                        } else {
                            FontFamily ff = new FontFamily(parser);
                            if (null != ff.alias && null != ff.family) {
                                fontFamilies.add(ff);
                            }
                        }
                        break;
                    default:
                        skipElement(parser);
                        break;
                }
            }

            afx.close();

            for (FontFamily o: fontFamilies) {
                o.write(outputXML);
            }

            outputXML.endTag(null, "fontconfig");
            outputXML.endDocument();
        } catch (IOException | XmlPullParserException e) {
            e.printStackTrace();
        }
    }

    static class FontElement {
        protected String alias;
        protected String family;

        void write(XmlSerializer s) throws IOException {
            if (null != this.alias && null != this.family) {
                s.startTag(null, "alias");

                s.startTag(null, "family");
                s.text(this.alias);
                s.endTag(null, "family");

                s.startTag(null, "prefer");
                s.startTag(null, "family");
                s.text(this.family);
                s.endTag(null, "family");
                s.endTag(null, "prefer");

                s.endTag(null, "alias");
            }
        }
    }

    static class LegacyFontFamily {
        final List<String> aliases = new LinkedList<>();
        final String family;

        LegacyFontFamily(XmlPullParser parser) throws IOException, XmlPullParserException {
            parser.require(XmlPullParser.START_TAG, null, "family");

            List<String> filenames = new LinkedList<>();

            while (XmlPullParser.END_TAG != parser.next()) {
                if (XmlPullParser.START_TAG != parser.getEventType()) {
                    continue;
                }

                String outerElement = parser.getName();
                if (!outerElement.equals("nameset") && !outerElement.equals("fileset")) {
                    skipElement(parser);
                    continue;
                }

                while (XmlPullParser.END_TAG != parser.next()) {
                    if (XmlPullParser.START_TAG != parser.getEventType()) {
                        continue;
                    }

                    String innerElement = parser.getName();
                    if (!innerElement.equals("name") && !innerElement.equals("file")) {
                        skipElement(parser);
                        continue;
                    }

                    if (XmlPullParser.TEXT == parser.next()) {
                        String textElement = parser.getText();
                        if (null != textElement && !textElement.isEmpty()) {
                            if (innerElement.equals("name")) {
                                aliases.add(textElement);
                            } else {
                                filenames.add(textElement);
                            }
                        }
                        parser.nextTag();
                    }
                }
            }
            parser.require(XmlPullParser.END_TAG, null, "family");

            this.family = removeCommonSuffixes(getCommonPrefix(filenames));
        }

        void write(XmlSerializer s) throws IOException {
            class LegacyFontFamilyI extends FontElement {
                LegacyFontFamilyI(String alias, String family) {
                    this.alias = alias;
                    this.family = family;
                }
            }

            if (!this.family.isEmpty()) {
                for (String alias : aliases) {
                    new LegacyFontFamilyI(alias, this.family).write(s);
                }
            }
        }
    }

    static class FontFamily extends FontElement {
        FontFamily(XmlPullParser parser) throws IOException, XmlPullParserException {
            parser.require(XmlPullParser.START_TAG, null, "family");

            String alias = parser.getAttributeValue(null, "name");

            if (null == alias) {
                skipElement(parser);
                return;
            }

            List<String> filenames = new LinkedList<>();
            while (XmlPullParser.END_TAG != parser.next()) {
                if (XmlPullParser.START_TAG != parser.getEventType()) {
                    continue;
                }
                if ("font".equals(parser.getName())) {
                    if (XmlPullParser.TEXT == parser.next()) {
                        String filename = parser.getText();
                        if (null != filename && !filename.isEmpty()) {
                            filenames.add(filename);
                        }
                        parser.nextTag();
                    }
                } else {
                    skipElement(parser);
                }
            }
            parser.require(XmlPullParser.END_TAG, null, "family");

            String family = removeCommonSuffixes(getCommonPrefix(filenames));
            if (null != alias && !family.isEmpty()) {
                this.alias = alias;
                this.family = family;
            } else {
                this.alias = null;
                this.family = null;
            }
        }
    }

    static class FontAlias extends FontElement {
        final String alias;
        final String family;

        FontAlias(XmlPullParser parser) throws IOException, XmlPullParserException {
            parser.require(XmlPullParser.START_TAG, null, "alias");

            String alias = parser.getAttributeValue(null, "name");
            String family = parser.getAttributeValue(null, "to");

            String weight = parser.getAttributeValue(null, "weight");
            parser.nextTag();
            parser.require(XmlPullParser.END_TAG, null, "alias");

            // Discard weighted aliases, which alias to the same font
            // Fontconfig already handles them
            if (null == weight && !alias.startsWith(family)) {
                this.alias = alias;
                this.family = family;
            } else {
                this.alias = null;
                this.family = null;
            }
        }
    }

    private static String getCommonPrefix(List<String> input) {
        String result = null;
        for (String str: input) {
            if (null == result) {
                result = str;
            } else {
                if (result.length() > str.length()) {
                    result = result.substring(0, str.length());
                }
                for (int i = 0; i < result.length(); i++) {
                    if (result.charAt(i) != str.charAt(i)) {
                        result = result.substring(0, i);
                    }
                }
            }
        }
        return (null != result) ? result : "";
    }

    private static String removeCommonSuffixes(@NonNull String input) {
        String str = removeFilenameExtension(input);
        String strUpper = str.toUpperCase();

        List<String> suffixes = Arrays.asList("-", "ITALIC", "THIN", "LIGHT", "REGULAR", "MEDIUM", "BLACK", "BOLD");
        boolean changeMade;
        do {
            changeMade = false;
            for (String suffix: suffixes) {
                if (strUpper.endsWith(suffix)) {
                    strUpper = strUpper.substring(0, strUpper.length() - suffix.length());
                    changeMade = true;
                }
            }
        } while(changeMade);

        // Return to original case
        return str.substring(0, strUpper.length());
    }

    private static String removeFilenameExtension(String input) {
        int pos = input.lastIndexOf('.');
        if (-1 != pos) {
            return input.substring(0, pos);
        }
        return input;
    }

    private static void skipElement(XmlPullParser parser) throws XmlPullParserException, IOException {
        if (parser.getEventType() != XmlPullParser.START_TAG) {
            throw new IllegalStateException();
        }
        int depth = 1;
        while (depth != 0) {
            switch (parser.next()) {
                case XmlPullParser.END_TAG:
                    depth--;
                    break;
                case XmlPullParser.START_TAG:
                    depth++;
                    break;
            }
        }
    }
}
