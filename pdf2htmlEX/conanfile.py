import os

from conan import ConanFile
from conan.tools.cmake import CMakeToolchain, CMakeDeps

required_conan_version = ">=2.0.6"


class pdf2htmlEXConan(ConanFile):
    settings = "os", "compiler", "build_type", "arch"
    requires = "pdf2htmlex/0.18.8.rc1-20240905-git"

    def generate(self):
        deps = CMakeDeps(self)
        deps.generate()
        tc = CMakeToolchain(self)
        tc.generate()

        asset_dir = os.path.join(self.build_folder, 'assets')
        os.mkdir(asset_dir)
        os.symlink(self.dependencies['pdf2htmlex'].cpp_info.resdirs[0], os.path.join(asset_dir, 'pdf2htmlEX'))
        os.symlink(self.dependencies['poppler-data'].cpp_info.resdirs[0], os.path.join(asset_dir, 'poppler-data'))
        os.symlink(self.dependencies['fontconfig'].cpp_info.resdirs[0], os.path.join(asset_dir, 'fontconfig'))
