# /test/UnityBuildTargetsInheritDependenciesVerify.cmake
# Verifies the generated _unity target inherits all non-library
# dependencies - eg, that our custom command is run when running the unity-build target.
#
# See LICENCE.md for Copyright information.

include (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_TESTS_DIRECTORY}/CMakeUnit.cmake)
set (CUSTOM_COMMAND_OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/custom_command_output)

assert_file_exists (${CUSTOM_COMMAND_OUTPUT})