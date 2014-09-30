# /tests/NoIncludeWhatYouUseOption.cmake
# Tests upon setting the POLYSQUARE_USE_IWYU to FALSE that
# the following variables are unset
#  - _POLYSQUARE_BOOTSTRAPPED_CPPCHECK
#
# Finally, sets up a target so that we can later check that clang-tidy
# was not run on it
#
# See LICENCE.md for Copyright information

include (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY}/PolysquareCommon.cmake)
include (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_TESTS_DIRECTORY}/CMakeUnit.cmake)

set (POLYSQUARE_USE_IWYU OFF CACHE BOOL "" FORCE)

polysquare_compiler_bootstrap ()
polysquare_rules_bootstrap (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY}
                            ${CMAKE_CURRENT_BINARY_DIR}/polysquare)

set (SOURCE_FILE_CONTENTS "/* Copyright */\n")
set (SOURCE_FILE ${CMAKE_CURRENT_BINARY_DIR}/Source.cpp)
file (WRITE ${SOURCE_FILE} ${SOURCE_FILE_CONTENTS})

polysquare_add_library (library SHARED
                        SOURCES ${SOURCE_FILE})

polysquare_rules_complete_scanning ()

assert_variable_is_not_defined (_POLYSQUARE_BOOTSTRAPPED_IWYU)
