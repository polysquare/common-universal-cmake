# /tests/NoCPPCheckUnusedGeneratedOptionVerify.cmake
# Ensures that certain sources are never added to an unused function check.
#
# See LICENCE.md for Copyright information

include (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_TESTS_DIRECTORY}/CMakeUnit.cmake)

set (BUILD_OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/BUILD.output)

set (GENERATED_UNUSED_CHECK_REGEX
     "^.*cppcheck.*unusedFunction.*Generated\\.cpp.*$")
assert_file_does_not_contain (${BUILD_OUTPUT} ${GENERATED_UNUSED_CHECK_REGEX})
