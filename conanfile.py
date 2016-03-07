from conans import ConanFile
from conans.tools import download, unzip
import os

VERSION = "0.0.1"


class CommonUniversalCMakeCMakeConan(ConanFile):
    name = "common-universal-cmake"
    version = os.environ.get("CONAN_VERSION_OVERRIDE", VERSION)
    generators = "cmake"
    requires = (
        "accelerate-target-cmake/master@smspillaz/accelerate-target-cmake",
        "clang-tidy-target-cmake/master@smspillaz/clang-tidy-target-cmake",
        "cmake-include-guard/master@smspillaz/cmake-include-guard",
        "cmake-forward-arguments/master@smspillaz/cmake-forward-arguments",
        "cmake-unit/master@smspillaz/cmake-unit",
        "cppcheck-target-cmake/master@smspillaz/cppcheck-target-cmake",
        "gmock-cmake/master@smspillaz/gmock-cmake",
        "gcov-cmake/master@smspillaz/gcov-cmake",
        "iwyu-target-cmake/master@smspillaz/iwyu-target-cmake",
        "sanitize-target-cmake/master@smspillaz/sanitize-target-cmake",
        "verapp-cmake/master@smspillaz/verapp-cmake"
    )
    url = "http://github.com/polysquare/common-universal-cmake"
    license = "MIT"

    def source(self):
        zip_name = "common-universal-cmake.zip"
        download("https://github.com/polysquare/"
                 "common-universal-cmake/archive/{version}.zip"
                 "".format(version="v" + VERSION),
                 zip_name)
        unzip(zip_name)
        os.unlink(zip_name)

    def package(self):
        self.copy(pattern="*.cmake",
                  dst="cmake/common-universal-cmake",
                  src="common-universal-cmake-" + VERSION,
                  keep_path=True)
