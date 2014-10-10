# /tests/NoIncludeWhatYouUseOptionVerify.cmake
# Reads the build output to make sure that include-what-you-use was never
# run as part of the build.
#
# See LICENCE.md for Copyright information

include (CMakeUnit)

set (BUILD_OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/BUILD.output)

assert_file_does_not_contain (${BUILD_OUTPUT} "include-what-you-use")
