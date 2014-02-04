# /tests/NoVeraPPOption.cmake
# Tests upon setting the POLYSQARE_USE_VERAPP cache value to FALSE
# the following targets do not exist:
#  - The vera++ import targets, being:
#    * polysquare_verapp_copy_rules
#    * polysquare_verapp_copy_profiles
#    * polysquare_verapp_import_rules
#
# Also asserts that the following variables are unset
#  - _POLYSQUARE_VERAPP_PROFILE
#  - _POLYSQUARE_VERAPP_IMPORT_RULES
#
# Finally, sets up a target so that we can later check that vera++
# was not run on it
#
# See LICENCE.md for Copyright information

include (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY}/PolysquareCommon.cmake)
include (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_TESTS_DIRECTORY}/CMakeUnit.cmake)

set (POLYSQUARE_USE_VERAPP OFF CACHE BOOL "" FORCE)

polysquare_compiler_bootstrap ()
polysquare_rules_bootstrap (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY}
                            ${CMAKE_CURRENT_BINARY_DIR}/polysquare)

set (SOURCE_FILE_CONTENTS "")
set (SOURCE_FILE ${CMAKE_CURRENT_BINARY_DIR}/Source.cpp)
file (WRITE ${SOURCE_FILE} ${SOURCE_FILE_CONTENTS})

polysquare_add_library (library SHARED
                        SOURCES ${SOURCE_FILE})

assert_target_does_not_exist (polysquare_verapp_copy_rules)
assert_target_does_not_exist (polysquare_verapp_copy_profiles)
assert_target_does_not_exist (polysquare_verapp_import_rules)

assert_variable_is_not_defined (_POLYSQUARE_VERAPP_PROFILE)
assert_variable_is_not_defined (_POLYSQUARE_VERAPP_IMPORT_RULES)
