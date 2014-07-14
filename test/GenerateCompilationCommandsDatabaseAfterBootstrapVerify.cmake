# /tests/GenerateCompilationCommandsDatabaseAfterBootstrap.cmake
# Tests that a compile_commands.json is generated in the build directory 
#
# See LICENCE.md for Copyright information

include (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_TESTS_DIRECTORY}/CMakeUnit.cmake)

assert_file_exists (${CMAKE_CURRENT_BINARY_DIR}/compile_commands.json)