# /tests/ExternalHeadersAreSystemHeadersVerify.cmake
# Check that external headers got tagged with -isystem.
#
# See LICENCE.md for Copyright information

include (CMakeUnit)
set (BUILD_OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/BUILD.output)

assert_file_has_line_matching (${BUILD_OUTPUT} "^.*isystem .*External.*$")
assert_file_has_line_matching (${BUILD_OUTPUT} "^.*I.*Internal.*$")