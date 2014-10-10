# /tests/NoVeraPPOptionVerify.cmake
# Reads the build output to make sure that vera++ was never run as part of
# the build.
#
# See LICENCE.md for Copyright information

include (CMakeUnit)

set (BUILD_OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/BUILD.output)

assert_file_does_not_contain (${BUILD_OUTPUT} "vera++")
