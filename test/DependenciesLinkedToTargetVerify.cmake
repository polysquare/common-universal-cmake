# /test/DependenciesLinkedToTargetVerify.cmake
# Verifies that once our main target it built, custom_command_output has
# also been generated (eg the dependency was run)
#
# See LICENCE.md for Copyright information.

include (CMakeUnit)
set (CUSTOM_COMMAND_OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/custom_command_output)

assert_file_exists (${CUSTOM_COMMAND_OUTPUT})