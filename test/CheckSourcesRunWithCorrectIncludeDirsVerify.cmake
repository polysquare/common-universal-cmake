# /tests/CheckSourcesRunWithCorrectIncludeDirsVerify.cmake
# Checks the build output to make sure that:
# Source.cpp was compiled with -isystem.*external -I.*internal
# cppcheck was run with with -isystem.*external -I.*internal
# clang-tidy was run with with -isystem.*external -I.*internal
# include-what-you-use was run with with -isystem.*external -I.*internal
#
# See LICENCE.md for Copyright information

include (CMakeUnit)

set (BUILD_OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/BUILD.output)

# Location of compile_commands.json depends on our generator
if (CMAKE_GENERATOR STREQUAL "Ninja" OR
    CMAKE_GENERATOR STREQUAL "Unix Makefiles")

    set (COMPILE_COMMANDS
         ${CMAKE_CURRENT_BINARY_DIR}/compile_commands.json)

else (CMAKE_GENERATOR STREQUAL "Ninja" OR
      CMAKE_GENERATOR STREQUAL "Unix Makefiles")

    set (COMPILE_COMMANDS
         ${CMAKE_CURRENT_BINARY_DIR}/lib_compile_commands/compile_commands.json)

endif (CMAKE_GENERATOR STREQUAL "Ninja" OR
       CMAKE_GENERATOR STREQUAL "Unix Makefiles")

string (REPLACE "+" "." ESC_CXX_COMP "${CMAKE_CXX_COMPILER}")

# Position of include dirs may change between generators, check each
# include dir separately
set (COMPILE_LOCAL_INCLUDE_REGEX
     "^.*${ESC_CXX_COMP}.* -I.*internal.*Source.cpp.*$")
set (COMPILE_SYSTEM_INCLUDE_REGEX
     "^.*${ESC_CXX_COMP}.* -isystem.*external.*Source.cpp.*$")

set (CPPCHECK_REGEX
     "^.*cppcheck.* -I.*internal.*Source.cpp.*$")
set (CLANG_TIDY_SYSTEM_REGEX
     "^.*-isystem.*external.*Source.cpp.*$")
set (CLANG_TIDY_LOCAL_REGEX
     "^.*-I.*internal.*$")
set (IWYU_SYSTEM_REGEX
     "^.*include-.*-isystem.*external.*Source.cpp.*$")
set (IWYU_LOCAL_REGEX
     "^.*include-.*-I.*internal.*Source.cpp.*$")

assert_file_has_line_matching (${BUILD_OUTPUT} ${COMPILE_LOCAL_INCLUDE_REGEX})
assert_file_has_line_matching (${BUILD_OUTPUT} ${COMPILE_SYSTEM_INCLUDE_REGEX})
assert_file_has_line_matching (${BUILD_OUTPUT} ${CPPCHECK_REGEX})
assert_file_has_line_matching (${BUILD_OUTPUT} ${IWYU_LOCAL_REGEX})
assert_file_has_line_matching (${BUILD_OUTPUT} ${IWYU_SYSTEM_REGEX})
assert_file_has_line_matching (${BUILD_OUTPUT} ${CLANG_TIDY_LOCAL_REGEX})
assert_file_has_line_matching (${BUILD_OUTPUT} ${CLANG_TIDY_SYSTEM_REGEX})