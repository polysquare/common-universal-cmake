# /tests/NoBuildTestsOption.cmake
# Tests upon setting the POLYSQARE_BUILD_TESTS cache value to FALSE
# the following targets do not exist:
#  - The "GoogleMock" external project target
#  - Any "gtest" or "gmock" targets
#  - Any targets added with polysquare_add_test
#  - Any targets added with polysquare_add_matcher
#  - Any targets added with polysqaure_add_mock
#
# See LICENCE.md for Copyright information

include (PolysquareCommon)
include (CMakeUnit)

set (POLYSQUARE_BUILD_TESTS OFF CACHE BOOL "" FORCE)

polysquare_gmock_bootstrap (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY})

set (SOURCE_FILE_CONTENTS "")
set (SOURCE_FILE ${CMAKE_CURRENT_BINARY_DIR}/Source.cpp)

polysquare_add_mock (matcher
                     SOURCES ${SOURCE_FILE}
                     INTERNAL_INCLUDE_DIRS ${CMAKE_CURRENT_SOURCE_DIR}
                     EXPORT_HEADER_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})

polysquare_add_mock (mock
                     SOURCES ${SOURCE_FILE}
                     INTERNAL_INCLUDE_DIRS ${CMAKE_CURRENT_SOURCE_DIR}
                     EXPORT_HEADER_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})

polysquare_add_test (unittest
                     SOURCES ${SOURCE_FILE}
                     MATCHERS matcher)

assert_target_does_not_exist (GoogleMock)
assert_target_does_not_exist (gtest)
assert_target_does_not_exist (gmock)

assert_target_does_not_exist (matcher)
assert_target_does_not_exist (mock)
assert_target_does_not_exist (unittest)
