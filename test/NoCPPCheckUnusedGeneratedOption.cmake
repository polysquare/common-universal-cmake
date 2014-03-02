# /tests/NoCPPCheckUnusedGeneratedOption.cmake
# Tests that upon adding a library with NO_UNUSED_GENERATED_CHECK set
# that the implicit global unused function check does exist, but later
# checks in the verify stage that it is not run on generated sources.
#
# See LICENCE.md for Copyright information

include (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY}/PolysquareCommon.cmake)
include (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_TESTS_DIRECTORY}/CMakeUnit.cmake)

polysquare_compiler_bootstrap ()
polysquare_rules_bootstrap (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY}
                            ${CMAKE_CURRENT_BINARY_DIR}/polysquare)

set (NATIVE_SOURCE_FILE_CONTENTS "/* Copyright */\n")
set (NATIVE_SOURCE_FILE ${CMAKE_CURRENT_BINARY_DIR}/Source.cpp)
file (WRITE ${NATIVE_SOURCE_FILE} ${SOURCE_FILE_CONTENTS})

set (GENERATED_SOURCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/Generated.cpp)

add_custom_command (OUTPUT ${GENERATED_SOURCE_FILE}
                    COMMAND ${CMAKE_COMMAND} -E touch ${GENERATED_SOURCE_FILE})

polysquare_add_library (library SHARED
                        SOURCES
                        ${NATIVE_SOURCE_FILE}
                        ${GENERATED_SOURCE_FILE}
                        NO_UNUSED_GENERATED_CHECK
                        NO_VERAPP)

polysquare_rules_complete_scanning ()

assert_target_exists (polysquare_check_all_unused)
