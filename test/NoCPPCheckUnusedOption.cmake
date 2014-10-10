# /tests/NoCPPCheckUnusedOption.cmake
# Tests that upon adding a library with NO_UNUSED_CHECK set
# that the implicit global unused function check target does not
# exist. 
#
# See LICENCE.md for Copyright information

include (PolysquareCommon)
include (CMakeUnit)

polysquare_compiler_bootstrap ()
polysquare_rules_bootstrap (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY}
                            ${CMAKE_CURRENT_BINARY_DIR}/polysquare)

set (SOURCE_FILE_CONTENTS "/* Copyright */\n")
set (SOURCE_FILE ${CMAKE_CURRENT_BINARY_DIR}/Source.cpp)
file (WRITE ${SOURCE_FILE} ${SOURCE_FILE_CONTENTS})

polysquare_add_library (library SHARED
                        SOURCES ${SOURCE_FILE}
                        NO_UNUSED_CHECK)

polysquare_rules_complete_scanning ()

assert_target_does_not_exist (polysquare_check_all_unused)
