import os
from pathlib import Path

from conan import ConanFile
from conan.tools.cmake import CMake, cmake_layout
from conan.tools.build import can_run


class FontForgeTestConan(ConanFile):
    settings = "os", "compiler", "build_type", "arch"
    generators = "CMakeDeps", "CMakeToolchain"

    def requirements(self):
        self.requires(self.tested_reference_str)

    def build(self):
        cmake = CMake(self)
        cmake.configure()
        cmake.build()

    def layout(self):
        cmake_layout(self)

    def test(self):
        bin_path = os.path.join(self.cpp.build.bindir, "link_test")
        if can_run(self):
            self.run(bin_path, env="conanrun")

        elif self.settings.os == "Android":
            uploaded_dir = "/data/local/tmp/pdf2htmlex-test"

            if self.run(f"adb shell mkdir {uploaded_dir}", env="conanrun", ignore_errors=True) == 0:
                self.run(f"adb push {bin_path} {uploaded_dir}/link_test", env="conanrun")
                self.run(f"adb shell {uploaded_dir}/link_test", env="conanrun")

                self.run(f"adb push {self.dependencies['pdf2htmlex'].cpp_info.bindirs[0]}/pdf2htmlEX {uploaded_dir}", env="conanrun")
                self.run(f"adb push {self.dependencies['pdf2htmlex'].cpp_info.resdirs[0]} {uploaded_dir}/pdf2htmlex-data", env="conanrun")
                self.run(f"adb push {self.dependencies['poppler-data'].cpp_info.resdirs[0]} {uploaded_dir}/poppler-data", env="conanrun")
                self.run(f"adb push {self.dependencies['fontconfig'].cpp_info.resdirs[0]} {uploaded_dir}/fontconfig", env="conanrun")
                self.run(f"adb push {Path(Path(__file__).resolve().parent, "basic_text.pdf")} {uploaded_dir}/basic_text.pdf", env="conanrun")
                self.run(f"adb shell \""
                         f"export FONTCONFIG_PATH={uploaded_dir}/fontconfig; "
                         f"export TMPDIR=/data/local/tmp; "
                         f"cd {uploaded_dir}; "
                         f"./pdf2htmlEX basic_text.pdf basic_text.html "
                         f"--data-dir {uploaded_dir}/pdf2htmlex-data "
                         f"--poppler-data-dir {uploaded_dir}/poppler-data "
                         f"\"")

                self.run(f"adb shell rm -r {uploaded_dir}", env="conanrun")
