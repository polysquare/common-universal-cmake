# /tests/CheckSourcesRunWithCorrectIncludeDirs.cmake
# Checks the build output to make sure that:
# Source.cpp was compiled with -isystem.*external -I.*internal
# cppcheck was run with with -isystem.*external -I.*internal
# clang-tidy was run with with -isystem.*external -I.*internal
# include-what-you-use was run with with -isystem.*external -I.*internal
#
# See LICENCE.md for Copyright information

include (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_TESTS_DIRECTORY}/CMakeUnit.cmake)

set (BUILD_OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/BUILD.output)
set (COMPILE_COMMANDS
     ${CMAKE_CURRENT_BINARY_DIR}/compile_commands.json)

string (REPLACE "+" "." ESC_CXX_COMP "${CMAKE_CXX_COMPILER}")

set (COMPILE_REGEX
     "^.*${ESC_CXX_COMP}.* -isystem.*external.* -I.*internal.*Source.cpp.*$")
set (CPPCHECK_REGEX
     "^.*cppcheck.* -I.*internal.*Source.cpp.*$")
set (CLANG_TIDY_REGEX
     "^.*-isystem.*external.* -I.*internal.*Source.cpp.*$")
set (IWYU_REGEX
     "^.*include-.*-isystem.*external.* -I.*internal.*Source.cpp.*$")

assert_file_has_line_matching (${BUILD_OUTPUT} ${COMPILE_REGEX})
assert_file_has_line_matching (${BUILD_OUTPUT} ${CPPCHECK_REGEX})
assert_file_has_line_matching (${BUILD_OUTPUT} ${IWYU_REGEX})
assert_file_has_line_matching (${COMPILE_COMMANDS} ${CLANG_TIDY_REGEX})