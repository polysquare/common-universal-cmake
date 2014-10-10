# /tests/GenerateCompilationCommandsDatabaseAfterBootstrap.cmake
# Tests that a compile_commands.json is generated in the build directory 
#
# See LICENCE.md for Copyright information

include (CMakeUnit)

assert_file_exists (${CMAKE_CURRENT_BINARY_DIR}/compile_commands.json)