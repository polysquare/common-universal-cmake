# /tests/CheckSourcesTargetCreated.cmake
# Adds some sources to be checked as part of a source group
# and ensures that both the ${SOURCE_GROUP}_scannable target
# is created as well as the ${SOURCE_GROUP} target.
#
# Checks that a new target is created when adding the check.
#
# See LICENCE.md for Copyright information

include (PolysquareCommon)
include (CMakeUnit)

polysquare_rules_bootstrap (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY}
                            ${CMAKE_CURRENT_BINARY_DIR}/polysquare)

set (SOURCE_GROUP source_group)

set (SOURCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/Source.cpp)
set (SOURCE_FILE_CONTENTS
     "/* Copyright */\n"
     "void function ()\n"
     "{\n"
     "}\n")

file (WRITE ${SOURCE_FILE} ${SOURCE_FILE_CONTENTS})

set (SOURCES ${SOURCE_FILE})

polysquare_add_checked_sources (${SOURCE_GROUP}
                                SOURCES ${SOURCES})

assert_target_exists (${SOURCE_GROUP})
assert_target_exists (${SOURCE_GROUP}_scannable)