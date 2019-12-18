/*
 * FontconfigInstrumentedTests.java
 *
 * Copyright (C) 2019 Vilius Sutkus'89
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

package com.viliussutkus89.android.pdf2htmlex;

import androidx.test.ext.junit.runners.AndroidJUnit4;
import androidx.test.platform.app.InstrumentationRegistry;

import org.junit.Test;
import org.junit.runner.RunWith;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

@RunWith(AndroidJUnit4.class)
public class FontconfigInstrumentedTests {
    //pdf base14 fonts:
    //Courier, Courier Bold, Courier Oblique, Courier Bold-Oblique
    //Helvetica, Helvetica Bold, Helvetica Oblique, Helvetica Bold-Oblique
    //Times Roman, Times Bold, Times Italic, Times Bold-Italic
    //Symbol
    //Zapf Dingbats

    @Test
    public synchronized void matchCourierTest() {
        Set<String> acceptedValues = new HashSet<>(Arrays.asList("CutiveMono.ttf", "DroidSansMono.ttf"));

        // @TODO: init only FontconfigAndroid, not the whole pdf2htmlEX
        new pdf2htmlEX(InstrumentationRegistry.getInstrumentation().getTargetContext());
        assertTrue(acceptedValues.contains(getFontFilenameFromFontconfig("Courier")));

        // @TODO: these should be downloaded at run time
        assertTrue(acceptedValues.contains(getFontFilenameFromFontconfig("Courier:Bold")));
        assertTrue(acceptedValues.contains(getFontFilenameFromFontconfig("Courier:Oblique")));
        assertTrue(acceptedValues.contains(getFontFilenameFromFontconfig("Courier:Bold:Oblique")));
    }

    @Test
    public synchronized void matchHelveticaTest() {
        // @TODO: init only FontconfigAndroid, not the whole pdf2htmlEX
        new pdf2htmlEX(InstrumentationRegistry.getInstrumentation().getTargetContext());

        // /system/fonts/DroidSans.ttf symlinked to Roboto-Regular.ttf
        assertTrue(new HashSet<>(Arrays.asList("Roboto-Regular.ttf", "DroidSans.ttf"))
            .contains(getFontFilenameFromFontconfig("Helvetica")));

        // /system/fonts/DroidSans-Bold.ttf symlinked to Roboto-Bold.ttf
        assertTrue(new HashSet<>(Arrays.asList("Roboto-Bold.ttf", "DroidSans-Bold.ttf"))
            .contains(getFontFilenameFromFontconfig("Helvetica:Bold")));

        assertEquals("Roboto-Italic.ttf", getFontFilenameFromFontconfig("Helvetica:Oblique"));
        assertEquals("Roboto-BoldItalic.ttf", getFontFilenameFromFontconfig("Helvetica:Bold:Oblique"));
    }

    @Test
    public synchronized void matchTimesTest() {
        // @TODO: init only FontconfigAndroid, not the whole pdf2htmlEX
        new pdf2htmlEX(InstrumentationRegistry.getInstrumentation().getTargetContext());

        assertTrue(new HashSet<>(Arrays.asList("NotoSerif-Regular.ttf", "DroidSerif-Regular.ttf"))
            .contains(getFontFilenameFromFontconfig("Times")));

        assertTrue(new HashSet<>(Arrays.asList("NotoSerif-Bold.ttf", "DroidSerif-Bold.ttf"))
                .contains(getFontFilenameFromFontconfig("Times:Bold")));

        assertTrue(new HashSet<>(Arrays.asList("NotoSerif-Italic.ttf", "DroidSerif-Italic.ttf"))
                .contains(getFontFilenameFromFontconfig("Times:Italic")));

        assertTrue(new HashSet<>(Arrays.asList("NotoSerif-BoldItalic.ttf", "DroidSerif-BoldItalic.ttf"))
                .contains(getFontFilenameFromFontconfig("Times:Bold:Italic")));
    }

    @Test
    public synchronized void matchSymbolTest() {
        // @TODO: init only FontconfigAndroid, not the whole pdf2htmlEX
        new pdf2htmlEX(InstrumentationRegistry.getInstrumentation().getTargetContext());

        assertEquals("s050000l.pfb", getFontFilenameFromFontconfig("Symbol"));
        assertEquals("s050000l.pfb", getFontFilenameFromFontconfig("StandardSymbolsL"));
        assertEquals("s050000l.pfb", getFontFilenameFromFontconfig("Standard Symbols L"));
    }

    @Test
    public synchronized void matchDingbatsTest() {
        // @TODO: init only FontconfigAndroid, not the whole pdf2htmlEX
        new pdf2htmlEX(InstrumentationRegistry.getInstrumentation().getTargetContext());

        assertEquals("d050000l.pfb", getFontFilenameFromFontconfig("Dingbats"));
        assertEquals("d050000l.pfb", getFontFilenameFromFontconfig("ZapfDingbats"));
        assertEquals("d050000l.pfb", getFontFilenameFromFontconfig("Zapf Dingbats"));
    }

    public static native String getFontFilenameFromFontconfig(String pattern);
}
