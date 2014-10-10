# /tests/NoCPPCheckUnusedOptionVerify.cmake
# Ensures that certain sources are never added to an unused function check.
#
# See LICENCE.md for Copyright information

include (CMakeUnit)

set (BUILD_OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/BUILD.output)

assert_file_does_not_contain (${BUILD_OUTPUT} "^.*cppcheck.*unusedFunction.*$")
