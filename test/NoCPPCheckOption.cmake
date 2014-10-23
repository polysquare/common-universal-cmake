# /tests/NoCPPCheckOption.cmake
# Tests upon setting the POLYSQARE_USE_CPPCHECK cache value to FALSE
# the following targets do not exist:
#  - The "polysquare_check_unused" target
#
# Also asserts that the following variables are unset
#  - _POLYSQUARE_BOOTSTRAPPED_CPPCHECK
#
# Finally, sets up a target so that we can later check that cppcheck
# was not run on it
#
# See LICENCE.md for Copyright information

include (PolysquareCommon)
include (CMakeUnit)

set (POLYSQUARE_USE_CPPCHECK OFF CACHE BOOL "" FORCE)

polysquare_compiler_bootstrap ()
polysquare_rules_bootstrap ()

set (SOURCE_FILE_CONTENTS "/* Copyright */\n")
set (SOURCE_FILE ${CMAKE_CURRENT_BINARY_DIR}/Source.cpp)
file (WRITE ${SOURCE_FILE} ${SOURCE_FILE_CONTENTS})

polysquare_add_library (library SHARED
                        SOURCES ${SOURCE_FILE})

polysquare_rules_complete_scanning ()

assert_target_does_not_exist (polysquare_check_all_unused)

assert_variable_is_not_defined (_POLYSQUARE_BOOTSTRAPPED_CPPCHECK)
