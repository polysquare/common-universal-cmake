# /tests/CheckSourcesRunWithCorrectDefines.cmake
# Checks the build output to make sure that:
# Source.cpp was compiled with -DCUSTOM_DEFINITION=true
# cppcheck was run with -DCUSTOM_DEFINITION=true
# clang-tidy was run with -DCUSTOM_DEFINITION=true
# include-what-you-use was run with -DCUSTOM_DEFINITION=true
#
# See LICENCE.md for Copyright information

include (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_TESTS_DIRECTORY}/CMakeUnit.cmake)

set (BUILD_OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/BUILD.output)
set (COMPILE_COMMANDS
     ${CMAKE_CURRENT_BINARY_DIR}/compile_commands.json)

string (REPLACE "+" "." ESC_CXX_COMP "${CMAKE_CXX_COMPILER}")

set (COMPILE_REGEX
     "^.*${ESC_CXX_COMP}.*-DCUSTOM_DEFINITION=true.*Source.cpp.*$")
set (CPPCHECK_REGEX
     "^.*cppcheck.*-DCUSTOM_DEFINITION=true.*Source.cpp.*$")
set (CLANG_TIDY_REGEX
     "^.*-DCUSTOM_DEFINITION=true.*Source.cpp.*$")
set (IWYU_REGEX
     "^.*include-what-you-use.*-DCUSTOM_DEFINITION=true.*Source.cpp")

assert_file_has_line_matching (${BUILD_OUTPUT} ${COMPILE_REGEX})
assert_file_has_line_matching (${BUILD_OUTPUT} ${CPPCHECK_REGEX})
assert_file_has_line_matching (${BUILD_OUTPUT} ${IWYU_REGEX})
assert_file_has_line_matching (${COMPILE_COMMANDS} ${CLANG_TIDY_REGEX})