# /tests/GlobalUnusedFunctionCheckByDefault.cmake
# Bootstraps polysquare's CPPCheck machinery and then adds a new library,
# checking that a global unused funciton check called
# polysquare_check_all_unused.
#
# See LICENCE.md for Copyright information

include (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY}/PolysquareCommon.cmake)
include (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_TESTS_DIRECTORY}/CMakeUnit.cmake)

polysquare_rules_bootstrap (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY}
                            ${CMAKE_CURRENT_BINARY_DIR}/polysquare)

set (SOURCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/Source.cpp)
set (SOURCE_FILE_CONTENTS)
file (WRITE ${SOURCE_FILE} "")

polysquare_add_library (library SHARED
                        SOURCES
                        ${SOURCE_FILE}
                        INTERNAL_INCLUDE_DIRS "/var"
                        EXTERNAL_INCLUDE_DIRS "/usr"
                        NO_VERAPP)

polysquare_rules_complete_scanning ()

assert_target_exists (polysquare_check_all_unused)
