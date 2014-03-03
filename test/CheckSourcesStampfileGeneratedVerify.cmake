# /tests/CheckSourcesStampfileGeneratedVerify.cmake
# Verifies that after the build a stampfile with the target name is
# created in the binary directory.
#
# See LICENCE.md for Copyright information.

include (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_TESTS_DIRECTORY}/CMakeUnit.cmake)

set (STAMPFILE ${CMAKE_CURRENT_BINARY_DIR}/source_group.stamp)

assert_file_exists (${STAMPFILE})
