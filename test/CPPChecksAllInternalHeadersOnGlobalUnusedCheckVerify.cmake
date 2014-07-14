# /tests/CPPChecksOnAllInternalHeadersOnGlobalUnusedCheckVerify.cmake
# Checks the build output to make sure that cppcheck was run with the internal
# header flag set
#
# See LICENCE.md for Copyright information

include (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_TESTS_DIRECTORY}/CMakeUnit.cmake)

set (BUILD_OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/BUILD.output)

assert_file_has_line_matching (${BUILD_OUTPUT}
                               "^.*cppcheck.*unusedFunction.*-I\/var.*$")
assert_file_does_not_have_line_matching (${BUILD_OUTPUT}
                                         "^.*cppcheck.*unusedFunction.*-I\/etc.*$")
