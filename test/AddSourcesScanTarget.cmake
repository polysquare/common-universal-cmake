# /tests/AddSourcesScanTarget.cmake
# Adds a new target with arbitary sources and
# runs rule checkers on them
#
# See LICENCE.md for Copyright information

include (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY}/PolysquareCommon.cmake)
include (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_TESTS_DIRECTORY}/CMakeUnit.cmake)

polysquare_rules_bootstrap (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY}
                            ${CMAKE_CURRENT_BINARY_DIR}/polysquare)
polysquare_gmock_bootstrap (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY})

set (HEADER_FILE ${CMAKE_CURRENT_SOURCE_DIR}/Header.h)
set (HEADER_FILE_CONTENTS
     "/* Copyright */\n"
     "#ifndef HEADER_FILE\n"
     "#define HEADER_FILE\n"
     "bool function ()\;\n"
     "#endif\n")
file (WRITE ${HEADER_FILE} ${HEADER_FILE_CONTENTS})

polysquare_add_checked_sources (headers_check
                                SOURCES
                                ${HEADER_FILE})

assert_target_exists (headers_check)
