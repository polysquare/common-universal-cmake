# /tests/OverrideUnusedCheckWithGroupPropertyVerify.cmake
# Checks the build output to make sure that the source added to the unused
# check group had an unused check run over it.
#
# See LICENCE.md for Copyright information

include (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_TESTS_DIRECTORY}/CMakeUnit.cmake)

set (BUILD_OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/BUILD.output)

set (UNUSED_CHECK_LIBRARIES_STAMP
     "^.*unused_check_libraries.stamp.*$")
assert_file_has_line_matching (${BUILD_OUTPUT}
                               ${UNUSED_CHECK_LIBRARIES_STAMP})
assert_file_has_line_matching (${BUILD_OUTPUT}
                               "^.*cppcheck.*unusedFunction.*Source\\.cpp.*$")