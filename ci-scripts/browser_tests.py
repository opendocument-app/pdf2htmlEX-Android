#!/usr/bin/env python3
# A lot of test logic taken from
# https://github.com/pdf2htmlEX/pdf2htmlEX/blob/v0.18.8.rc1/pdf2htmlEX/test/browser_tests.py

import argparse
import os
import sys
import time

from PIL import Image, ImageChops
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions
from selenium.webdriver.support.ui import WebDriverWait


def main():
    parser = argparse.ArgumentParser(description="Render test HTMLs into PNGs and compare against reference PNGs")
    parser.add_argument("--html-dir", action="store", required=True,
                        help="Directory with converted HTMLs")
    parser.add_argument("--png-destination-dir", action="store", required=True,
                        help="Directory where to save rendered PNGs")
    parser.add_argument("--reference-png-dir", action="store", required=True,
                        help="Directory with reference PNGs")
    args = parser.parse_args()
    del parser

    tests = ["basic_text", "fontfile3_opentype", "geneve_1564", "invalid_unicode_issue477", "issue_83", "pdf", "sample", "svg_background_with_page_rotation_issue402", "test_fail", "text_visibility", "with_form"]

    test_result = True

    html_dir = os.path.abspath(args.html_dir)
    reference_png_dir = os.path.abspath(args.reference_png_dir)
    png_destination_dir = os.path.abspath(args.png_destination_dir)
    if not os.path.exists(png_destination_dir):
        os.mkdir(png_destination_dir, 0o755)

    os.environ["MOZ_HEADLESS"] = "1"
    for test in tests:
        html_file = os.path.join(html_dir, f"{test}/{test}.html")
        png_file = os.path.join(png_destination_dir, f"{test}.png")
        reference_png_file = os.path.join(reference_png_dir, f"{test}.png")
        diff_png_file = os.path.join(png_destination_dir, f"{test}-diff.png")

        if not os.path.exists(html_file):
            test_result = False
            print(f"  FAILURE: {test} html file not found!")
            continue

        browser = webdriver.Firefox()
        browser.set_window_size(600, 800)
        try:
            browser.get('file://' + html_file)
            WebDriverWait(browser, 5) \
                .until(expected_conditions.presence_of_element_located((By.ID, 'page-container')))
        finally:
            time.sleep(1)
            browser.get_full_page_screenshot_as_file(png_file)
            browser.quit()

        if not os.path.exists(reference_png_file):
            print(f'  IGNORED: {test} reference png file not found')
            continue

        out_img = Image.open(png_file).convert('RGB')
        ref_img = Image.open(reference_png_file).convert('RGB')

        diff_img = ImageChops.difference(ref_img, out_img)
        diff_img.convert('RGB').save(diff_png_file)

        diff_bbox = diff_img.getbbox()
        if test == "test_fail":
            if diff_bbox is None:
                test_result = False
                print(f"  FAILURE: {test} should fail, but it did not. "
                      f"Test system is potentially broken.")
            else:
                print(f"  SUCCESS: {test}")
        elif diff_bbox is None:
            print(f"  SUCCESS: {test}")
        else:
            test_result = False
            print(f"  FAILURE: {test} diff bounding box: {diff_bbox} should be None")
            diff_size = (diff_bbox[2] - diff_bbox[0]) * (diff_bbox[3] - diff_bbox[1])
            img_size = ref_img.size[0] * ref_img.size[1]
            print(f'PNG file {png_file} and {reference_png_file} differ by at'
                  f'most {diff_size} pixels, ({100.0*diff_size/img_size} of {img_size}'
                  f'pixels in total), difference: {diff_png_file}', file=sys.stderr)

    sys.exit(0 if test_result else 1)


if __name__ == "__main__":
    main()
