# /tests/ClangTidyEnableChecksPassed.cmake
# Bootstraps polysquare's clang-tidy machinery and then adds a target with
# clang-tidy enabled, explicitly enabling the "google-*" checks.
#
# See LICENCE.md for Copyright information

include (PolysquareCommon)
include (CMakeUnit)

polysquare_rules_bootstrap ()

set (SOURCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/Source.cpp)
set (SOURCE_FILE_CONTENTS
     "bool function()\n"
     "{\n"
     "    return true\;\n"
     "}\n")
file (WRITE ${SOURCE_FILE} ${SOURCE_FILE_CONTENTS})

polysquare_add_library (library SHARED
                        SOURCES
                        ${SOURCE_FILE}
                        CLANG_TIDY_ENABLE_CHECKS
                        google-*
                        NO_VERAPP)
