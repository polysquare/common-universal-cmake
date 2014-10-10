# /tests/CheckSourcesRunWithCorrectIncludeDirs.cmake
# Adds some custom definines to our library. The include dirs should be
# applied to all of its sources, plus any of its checks.
#
# See LICENCE.md for Copyright information

include (PolysquareCommon)
include (CMakeUnit)

polysquare_rules_bootstrap (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY}
                            ${CMAKE_CURRENT_BINARY_DIR}/polysquare)

set (SOURCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/Source.cpp)
set (SOURCE_FILE_CONTENTS
     "bool function()\n"
     "{\n"
     "    return true\;\n"
     "}\n")
file (WRITE ${SOURCE_FILE} ${SOURCE_FILE_CONTENTS})

polysquare_add_library (lib SHARED
                        SOURCES
                        ${SOURCE_FILE}
                        INTERNAL_INCLUDE_DIRS
                        ${CMAKE_CURRENT_BINARY_DIR}/internal
                        EXTERNAL_INCLUDE_DIRS
                        ${CMAKE_CURRENT_BINARY_DIR}/external
                        NO_VERAPP)
