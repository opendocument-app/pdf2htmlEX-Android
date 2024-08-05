#!/usr/bin/env python3

import json
import os


def main():
    # Rules for this generator:
    #
    # aosp_atd api_type_target available on emulator_api_level 30 and up,
    # emulator_api_level 29 and below use default api_type_target
    #
    # x86 arch available on emulator_api_level 30 and lower.
    #
    # emulator_api_level 35 is available only on api_type_target google_apis.
    # Don't use google_apis on previous emulator_api_levels
    emulator_api_levels = (35, 34, 33, 32, 31, 30, 29, 28, 27, 26, 25, 24, 23, 22, 21)
    arches = ("x86_64", "x86")
    api_type_targets = ("aosp_atd", "default", "google_apis")

    matrix = []
    for emulator_api_level in emulator_api_levels:
        for api_type_target in api_type_targets:
            for arch in arches:
                if emulator_api_level < 30 and api_type_target == "aosp_atd":
                    continue
                if emulator_api_level >= 30 and api_type_target == "default":
                    continue
                if emulator_api_level > 30 and arch == "x86":
                    continue
                if emulator_api_level >= 35 and api_type_target != "google_apis":
                    continue
                if emulator_api_level < 35 and api_type_target == "google_apis":
                    continue

                matrix.append({
                    "api_level": emulator_api_level,
                    "api_type_target": api_type_target,
                    "arch": arch,
                })

    for i in matrix:
        print('-', i)


    gh_output = os.environ.get('GITHUB_OUTPUT')
    if gh_output:
        with open(gh_output, 'w') as out:
            print("matrix=" + json.dumps(matrix), file=out)


if __name__ == "__main__":
    main()
