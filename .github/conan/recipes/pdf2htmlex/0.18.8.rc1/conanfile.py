import os
import stat

from conan import ConanFile
from conan.tools.cmake import CMakeToolchain, CMake, cmake_layout, CMakeDeps
from conan.tools.env import Environment
from conan.tools.files import apply_conandata_patches, copy, export_conandata_patches, get, rmdir
from conan.errors import ConanInvalidConfiguration

required_conan_version = ">=2.0.6"


class pdf2htmlEXConan(ConanFile):
    name = "pdf2htmlex"
    package_type = "library"

    license = ["GPLv3-or-later", "MIT", "CC-BY-3.0"]
    homepage = "https://github.com/pdf2htmlEX/pdf2htmlEX"
    url = "https://github.com/opendocument-app/pdf2htmlEX-Android"
    description = "Convert PDF to HTML without losing text or format. "
    topics = ("PDF", "HTML", "pdf-document-processor", "pdf-viewer")

    # Binary configuration
    settings = "os", "compiler", "build_type", "arch"
    options = {"shared": [True, False], "fPIC": [True, False]}
    default_options = {"shared": False, "fPIC": True}

    def config_options(self):
        if self.settings.os == "Windows":
            self.options.rm_safe("fPIC")

    def configure(self):
        if self.options.shared:
            self.options.rm_safe("fPIC")

    def validate(self):
        if not self.dependencies["poppler"].options.with_cairo:
            raise ConanInvalidConfiguration('Dependency "poppler" needs to be built with "with_cairo" option')
        if not self.dependencies["poppler"].options.with_glib:
            raise ConanInvalidConfiguration('Dependency "poppler" needs to be built with "with_glib" option')
        if self.dependencies["poppler"].options.shared:
            raise ConanInvalidConfiguration('Dependency "poppler" needs to be built as a static library (shared=False)')
        if not self.dependencies["fontforge"].options.install_private_headers:
            raise ConanInvalidConfiguration(
                'Dependency "fontforge" needs to be built with "install_private_headers" option')

    def requirements(self):
        self.requires("poppler/24.08.0-odr", options={
            "with_cairo": True,
            "with_glib": True,
            "shared": False,
            "fontconfiguration": "fontconfig",
        }, transitive_headers=True, transitive_libs=True)
        self.requires("cairo/1.18.0-odr", options={
            # Don't pull in xorg dependencies.
            "with_xlib": False,
            "with_xlib_xrender": False,
            "with_xcb": False,
        }, transitive_headers=True, transitive_libs=True)
        self.requires("freetype/2.14.1")
        self.requires("fontforge/20240423-git", options={
            "install_private_headers": True,
        })

        self.requires("glib/2.81.0-odr")

        # self.requires("libtiff/4.6.0")
        # # jbig and libdeflate are required by libtiff
        # # Conan auto finds them, but linker doesn't, unless they're added here manually
        # self.requires("jbig/20160605")
        # self.requires("libdeflate/1.20")
        # self.requires("libiconv/1.17")
        # self.requires("giflib/5.2.2")

    def layout(self):
        cmake_layout(self, src_folder="src")

    def export_sources(self):
        export_conandata_patches(self)

    def source(self):
        get(self, **self.conan_data["sources"][self.version], strip_root=True)
        apply_conandata_patches(self)

        # @TODO: use build_tools for closure compiler and yuicompressor
        for executable in ["build_css.sh", "build_js.sh"]:
            exe = os.path.join(self.source_folder, "pdf2htmlEX", "share", executable)
            os.chmod(exe, os.stat(exe).st_mode | stat.S_IEXEC)

    def generate(self):
        deps = CMakeDeps(self)
        deps.generate()
        tc = CMakeToolchain(self)
        tc.extra_cxxflags = ["-Wno-maybe-uninitialized"]
        tc.variables["PDF2HTMLEX_VERSION"] = self.version
        tc.cache_variables["CMAKE_POLICY_VERSION_MINIMUM"] = "3.5"  # CMake 4 support

        # Get runenv info, exported by package_info() of dependencies
        # We need to obtain POPPLER_DATA_DIR and FONTCONFIG_PATH
        runenv_info = Environment()
        deps = self.dependencies.host.topological_sort
        deps = [dep for dep in reversed(deps.values())]
        for dep in deps:
            runenv_info.compose_env(dep.runenv_info)
        envvars = runenv_info.vars(self)
        for v in ["POPPLER_DATA_DIR", "FONTCONFIG_PATH"]:
            tc.variables[v] = envvars.get(v)
        # @TODO: figure out how to use POPPLER_DATA_DIR exported by poppler-data. It should JustWork^tm
        tc.generate()

    def build(self):
        cmake = CMake(self)
        cmake.configure(build_script_folder="pdf2htmlEX")
        cmake.build()

    def package(self):
        licensedir = os.path.join(self.package_folder, "licenses")
        copy(self, "LICENSE*", src=self.source_folder, dst=licensedir)
        copy(self, "LICENSE", src=os.path.join(self.source_folder, "pdf2htmlEX", "share"),
             dst=os.path.join(licensedir, "share"))
        copy(self, "LICENSE*", src=os.path.join(self.source_folder, "pdf2htmlEX", "logo"),
             dst=os.path.join(licensedir, "logo"))

        copy(
            self,
            "*.h",
            src=os.path.join(self.source_folder, "pdf2htmlEX", "src"),
            dst=os.path.join(self.package_folder, "include", "pdf2htmlEX"),
        )

        cmake = CMake(self)
        cmake.install()

        rmdir(self, os.path.join(self.package_folder, "share", "man"))

    def package_info(self):
        self.cpp_info.libs = ["pdf2htmlEX"]
        self.cpp_info.includedirs = ["include", "include/pdf2htmlEX"]
        self.cpp_info.resdirs = ["share/pdf2htmlEX"]

        pdf2htmlEX_data_dir = os.path.join(self.package_folder, "share", "pdf2htmlEX")
        self.runenv_info.define_path("PDF2HTMLEX_DATA_DIR", pdf2htmlEX_data_dir)
