# /tests/MatcherTargetHasExportedDetails.cmake
# Tests that a matcher has the correct exported bits.
#
# See LICENCE.md for Copyright information

include (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY}/PolysquareCommon.cmake)
include (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_TESTS_DIRECTORY}/CMakeUnit.cmake)

polysquare_gmock_bootstrap (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY})

set (MATCHER_SOURCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/Matcher.cpp)
set (MATCHER_HEADER_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
file (WRITE ${MATCHER_SOURCE_FILE} "")

polysquare_add_matcher (matcher
                        SOURCES ${MATCHER_SOURCE_FILE}
                        INTERNAL_INCLUDE_DIRS ${CMAKE_CURRENT_SOURCE_DIR}
                        EXPORT_HEADER_DIRECTORY ${MATCHER_HEADER_DIRECTORY})

assert_has_property_with_value (TARGET matcher
                                EXPORT_HEADER_DIRECTORY
                                STRING
                                EQUAL
                                ${MATCHER_HEADER_DIRECTORY})
