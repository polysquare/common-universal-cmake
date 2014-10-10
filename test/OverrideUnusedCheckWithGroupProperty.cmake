# /tests/OverrideUnusedCheckWithGroupProperty.cmake
# Bootstraps polysquare's CPPCheck machinery and then adds a new library,
# but passing the UNUSED_CHECK_GROUP property. Verifies that a new
# target is created with the same name as the group.
#
# See LICENCE.md for Copyright information

include (PolysquareCommon)
include (CMakeUnit)

polysquare_rules_bootstrap (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY}
                            ${CMAKE_CURRENT_BINARY_DIR}/polysquare)

set (SOURCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/Source.cpp)
set (SOURCE_FILE_CONTENTS)
file (WRITE ${SOURCE_FILE} "")

polysquare_add_library (library SHARED
                        SOURCES
                        ${SOURCE_FILE}
                        UNUSED_CHECK_GROUP unused_check_libraries
                        NO_VERAPP)

polysquare_rules_complete_scanning ()

assert_target_exists (unused_check_libraries)
