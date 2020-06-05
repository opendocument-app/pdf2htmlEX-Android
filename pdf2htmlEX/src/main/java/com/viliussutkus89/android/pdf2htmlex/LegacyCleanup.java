package com.viliussutkus89.android.pdf2htmlex;

import android.content.Context;

import java.io.File;

// Some files in previous releases were installed to a different location
// cleanup those files

final class LegacyCleanup {

    private static class LegacyEntry {
        private final String m_directory;
        private final String[] m_files;

        LegacyEntry(String directory, String[] files) {
            this.m_directory = directory;
            this.m_files = files;
        }

        void cleanup(File filesDirPrefix) {
            File filesDir = new File(filesDirPrefix, m_directory);
            if (!filesDir.exists() || !filesDir.isDirectory()) {
                return;
            }

            for (String file : m_files) {
                File f = new File(filesDir, file);
                if (f.exists() && f.isFile()) {
                    f.delete();
                }
            }

            try {
                String[] leftoverFilesInDir = filesDir.list();
                if (null != leftoverFilesInDir && 0 == leftoverFilesInDir.length) {
                    filesDir.delete();
                }
            } catch (SecurityException ignored) {
            }
        }
    }

    private static final LegacyEntry[] c_legacy_files_v0_18_10 = new LegacyEntry[]{
            new LegacyEntry("etc/fonts/conf.d", new String[]{
                    "10-hinting-slight.conf",
                    "10-scale-bitmap-fonts.conf",
                    "20-unhint-small-vera.conf",
                    "30-metric-aliases.conf",
                    "40-nonlatin.conf",
                    "45-generic.conf",
                    "45-latin.conf",
                    "49-sansserif.conf",
                    "50-user.conf",
                    "51-local.conf",
                    "60-generic.conf",
                    "60-latin.conf",
                    "65-fonts-persian.conf",
                    "65-nonlatin.conf",
                    "69-unifont.conf",
                    "80-delicious.conf",
                    "90-synthetic.conf",
                    "README"
            }),

            new LegacyEntry("etc/fonts", new String[]{
                    "fonts.conf",
                    "local.conf",
                    "system-etc-fonts-xml-translated.conf"
            }),

            new LegacyEntry("etc", new String[]{}),

            new LegacyEntry("fonts", new String[]{
                    "d050000l.pfb",
                    "s050000l.pfb"
            }),

            new LegacyEntry("pdf2htmlEX", new String[]{
                    "LICENSE",
                    "base.css",
                    "base.min.css",
                    "compatibility.js",
                    "compatibility.min.js",
                    "fancy.css",
                    "fancy.min.css",
                    "manifest",
                    "pdf2htmlEX-64x64.png",
                    "pdf2htmlEX.js",
                    "pdf2htmlEX.min.js"
            }),

            new LegacyEntry("poppler/cMap/Adobe-CNS1", new String[]{
                    "Adobe-CNS1-0",
                    "Adobe-CNS1-1",
                    "Adobe-CNS1-2",
                    "Adobe-CNS1-3",
                    "Adobe-CNS1-4",
                    "Adobe-CNS1-5",
                    "Adobe-CNS1-6",
                    "Adobe-CNS1-7",
                    "Adobe-CNS1-B5pc",
                    "Adobe-CNS1-ETen-B5",
                    "Adobe-CNS1-H-CID",
                    "Adobe-CNS1-H-Host",
                    "Adobe-CNS1-H-Mac",
                    "Adobe-CNS1-UCS2",
                    "B5-H",
                    "B5-V",
                    "B5pc-H",
                    "B5pc-UCS2",
                    "B5pc-UCS2C",
                    "B5pc-V",
                    "CNS-EUC-H",
                    "CNS-EUC-V",
                    "CNS1-H",
                    "CNS1-V",
                    "CNS2-H",
                    "CNS2-V",
                    "ETHK-B5-H",
                    "ETHK-B5-V",
                    "ETen-B5-H",
                    "ETen-B5-UCS2",
                    "ETen-B5-V",
                    "ETenms-B5-H",
                    "ETenms-B5-V",
                    "HKdla-B5-H",
                    "HKdla-B5-V",
                    "HKdlb-B5-H",
                    "HKdlb-B5-V",
                    "HKgccs-B5-H",
                    "HKgccs-B5-V",
                    "HKm314-B5-H",
                    "HKm314-B5-V",
                    "HKm471-B5-H",
                    "HKm471-B5-V",
                    "HKscs-B5-H",
                    "HKscs-B5-V",
                    "UCS2-B5pc",
                    "UCS2-ETen-B5",
                    "UniCNS-UCS2-H",
                    "UniCNS-UCS2-V",
                    "UniCNS-UTF16-H",
                    "UniCNS-UTF16-V",
                    "UniCNS-UTF32-H",
                    "UniCNS-UTF32-V",
                    "UniCNS-UTF8-H",
                    "UniCNS-UTF8-V"
            }),

            new LegacyEntry("poppler/cMap/Adobe-GB1", new String[]{
                    "Adobe-GB1-0",
                    "Adobe-GB1-1",
                    "Adobe-GB1-2",
                    "Adobe-GB1-3",
                    "Adobe-GB1-4",
                    "Adobe-GB1-5",
                    "Adobe-GB1-GBK-EUC",
                    "Adobe-GB1-GBpc-EUC",
                    "Adobe-GB1-H-CID",
                    "Adobe-GB1-H-Host",
                    "Adobe-GB1-H-Mac",
                    "Adobe-GB1-UCS2",
                    "GB-EUC-H",
                    "GB-EUC-V",
                    "GB-H",
                    "GB-V",
                    "GBK-EUC-H",
                    "GBK-EUC-UCS2",
                    "GBK-EUC-V",
                    "GBK2K-H",
                    "GBK2K-V",
                    "GBKp-EUC-H",
                    "GBKp-EUC-V",
                    "GBT-EUC-H",
                    "GBT-EUC-V",
                    "GBT-H",
                    "GBT-V",
                    "GBTpc-EUC-H",
                    "GBTpc-EUC-V",
                    "GBpc-EUC-H",
                    "GBpc-EUC-UCS2",
                    "GBpc-EUC-UCS2C",
                    "GBpc-EUC-V",
                    "UCS2-GBK-EUC",
                    "UCS2-GBpc-EUC",
                    "UniGB-UCS2-H",
                    "UniGB-UCS2-V",
                    "UniGB-UTF16-H",
                    "UniGB-UTF16-V",
                    "UniGB-UTF32-H",
                    "UniGB-UTF32-V",
                    "UniGB-UTF8-H",
                    "UniGB-UTF8-V"
            }),

            new LegacyEntry("poppler/cMap/Adobe-Japan1", new String[]{
                    "78-EUC-H",
                    "78-EUC-V",
                    "78-H",
                    "78-RKSJ-H",
                    "78-RKSJ-V",
                    "78-V",
                    "78ms-RKSJ-H",
                    "78ms-RKSJ-V",
                    "83pv-RKSJ-H",
                    "90ms-RKSJ-H",
                    "90ms-RKSJ-UCS2",
                    "90ms-RKSJ-V",
                    "90msp-RKSJ-H",
                    "90msp-RKSJ-V",
                    "90pv-RKSJ-H",
                    "90pv-RKSJ-UCS2",
                    "90pv-RKSJ-UCS2C",
                    "90pv-RKSJ-V",
                    "Add-H",
                    "Add-RKSJ-H",
                    "Add-RKSJ-V",
                    "Add-V",
                    "Adobe-Japan1-0",
                    "Adobe-Japan1-1",
                    "Adobe-Japan1-2",
                    "Adobe-Japan1-3",
                    "Adobe-Japan1-4",
                    "Adobe-Japan1-5",
                    "Adobe-Japan1-6",
                    "Adobe-Japan1-90ms-RKSJ",
                    "Adobe-Japan1-90pv-RKSJ",
                    "Adobe-Japan1-H-CID",
                    "Adobe-Japan1-H-Host",
                    "Adobe-Japan1-H-Mac",
                    "Adobe-Japan1-PS-H",
                    "Adobe-Japan1-PS-V",
                    "Adobe-Japan1-UCS2",
                    "EUC-H",
                    "EUC-V",
                    "Ext-H",
                    "Ext-RKSJ-H",
                    "Ext-RKSJ-V",
                    "Ext-V",
                    "H",
                    "Hankaku",
                    "Hiragana",
                    "Hojo-EUC-H",
                    "Hojo-EUC-V",
                    "Hojo-H",
                    "Hojo-V",
                    "Katakana",
                    "NWP-H",
                    "NWP-V",
                    "RKSJ-H",
                    "RKSJ-V",
                    "Roman",
                    "UCS2-90ms-RKSJ",
                    "UCS2-90pv-RKSJ",
                    "UniHojo-UCS2-H",
                    "UniHojo-UCS2-V",
                    "UniHojo-UTF16-H",
                    "UniHojo-UTF16-V",
                    "UniHojo-UTF32-H",
                    "UniHojo-UTF32-V",
                    "UniHojo-UTF8-H",
                    "UniHojo-UTF8-V",
                    "UniJIS-UCS2-H",
                    "UniJIS-UCS2-HW-H",
                    "UniJIS-UCS2-HW-V",
                    "UniJIS-UCS2-V",
                    "UniJIS-UTF16-H",
                    "UniJIS-UTF16-V",
                    "UniJIS-UTF32-H",
                    "UniJIS-UTF32-V",
                    "UniJIS-UTF8-H",
                    "UniJIS-UTF8-V",
                    "UniJIS2004-UTF16-H",
                    "UniJIS2004-UTF16-V",
                    "UniJIS2004-UTF32-H",
                    "UniJIS2004-UTF32-V",
                    "UniJIS2004-UTF8-H",
                    "UniJIS2004-UTF8-V",
                    "UniJISPro-UCS2-HW-V",
                    "UniJISPro-UCS2-V",
                    "UniJISPro-UTF8-V",
                    "UniJISX0213-UTF32-H",
                    "UniJISX0213-UTF32-V",
                    "UniJISX02132004-UTF32-H",
                    "UniJISX02132004-UTF32-V",
                    "WP-Symbol",
                    "V"
            }),

            new LegacyEntry("poppler/cMap/Adobe-Japan2", new String[]{
                    "Adobe-Japan2-0"
            }),

            new LegacyEntry("poppler/cMap/Adobe-Korea1", new String[]{
                    "Adobe-Korea1-0",
                    "Adobe-Korea1-1",
                    "Adobe-Korea1-2",
                    "Adobe-Korea1-H-CID",
                    "Adobe-Korea1-H-Host",
                    "Adobe-Korea1-H-Mac",
                    "Adobe-Korea1-KSCms-UHC",
                    "Adobe-Korea1-KSCpc-EUC",
                    "Adobe-Korea1-UCS2",
                    "KSC-EUC-H",
                    "KSC-EUC-V",
                    "KSC-H",
                    "KSC-Johab-H",
                    "KSC-Johab-V",
                    "KSC-V",
                    "KSCms-UHC-H",
                    "KSCms-UHC-HW-H",
                    "KSCms-UHC-HW-V",
                    "KSCms-UHC-UCS2",
                    "KSCms-UHC-V",
                    "KSCpc-EUC-H",
                    "KSCpc-EUC-UCS2",
                    "KSCpc-EUC-UCS2C",
                    "KSCpc-EUC-V",
                    "UCS2-KSCms-UHC",
                    "UCS2-KSCpc-EUC",
                    "UniKS-UCS2-H",
                    "UniKS-UCS2-V",
                    "UniKS-UTF16-H",
                    "UniKS-UTF16-V",
                    "UniKS-UTF32-H",
                    "UniKS-UTF32-V",
                    "UniKS-UTF8-H",
                    "UniKS-UTF8-V"
            }),

            new LegacyEntry("poppler/cMap", new String[]{}),

            new LegacyEntry("poppler/cidToUnicode", new String[]{
                    "Adobe-CNS1",
                    "Adobe-GB1",
                    "Adobe-Japan1",
                    "Adobe-Korea1"
            }),

            new LegacyEntry("poppler/nameToUnicode", new String[]{
                    "Bulgarian",
                    "Greek",
                    "Thai"
            }),

            new LegacyEntry("poppler/unicodeMap", new String[]{
                    "Big5",
                    "Big5ascii",
                    "EUC-CN",
                    "EUC-JP",
                    "GBK",
                    "ISO-2022-CN",
                    "ISO-2022-JP",
                    "ISO-2022-KR",
                    "ISO-8859-6",
                    "ISO-8859-7",
                    "ISO-8859-8",
                    "ISO-8859-9",
                    "KOI8-R",
                    "Latin2",
                    "Shift-JIS",
                    "TIS-620",
                    "Windows-1255"
            }),

            new LegacyEntry("poppler", new String[]{})
    };

    static void cleanup(Context ctx) {
        final File filesDir = ctx.getFilesDir();
        for (LegacyEntry e : c_legacy_files_v0_18_10) {
            e.cleanup(filesDir);
        }

        final File cacheDir = ctx.getCacheDir();

        final File[] legacyCaches = new File[] {
            new File(cacheDir, "homeForFontforge")
        };
        for (File cacheEntry: legacyCaches) {
            cacheEntry.delete();
        }

    }
}
