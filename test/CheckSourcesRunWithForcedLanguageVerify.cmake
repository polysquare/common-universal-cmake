# /tests/CheckSourcesRunWithForcedLanguageVerify.cmake
# Checks to make sure that:
# We ran cppcheck in C++ mode on the header file.
# We ran clang-tidy in C++ mode on the header file.
# We ran include-what-you-use in C++ mode on the header file.
#
# See LICENCE.md for Copyright information

include (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_TESTS_DIRECTORY}/CMakeUnit.cmake)

set (BUILD_OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/BUILD.output)
set (COMPILE_COMMANDS
     ${CMAKE_CURRENT_BINARY_DIR}/lib_compile_commands/compile_commands.json)

set (CPPCHECK_REGEX
     "^.*cppcheck.*--language=c...*Header.h.*$")
set (CLANG_TIDY_REGEX
     "^.*-x c.*Header.h.*$")
set (IWYU_REGEX
     "^.*include-what-you-use.*-x c.*Header.h")

# We can't check for the cppcheck regex on certain versions
if (NOT ${CPPCHECK_VERSION} VERSION_LESS 1.58)
    assert_file_has_line_matching (${BUILD_OUTPUT} ${CPPCHECK_REGEX})
endif (NOT ${CPPCHECK_VERSION} VERSION_LESS 1.58)
assert_file_has_line_matching (${BUILD_OUTPUT} ${IWYU_REGEX})
assert_file_has_line_matching (${COMPILE_COMMANDS} ${CLANG_TIDY_REGEX})