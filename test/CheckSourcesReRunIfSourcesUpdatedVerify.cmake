# /tests/CheckSourcesReRunIfSourcesUpdatedVerify.cmake
# Verifies that vera++ and cppcheck are run on our sources if targets
# which the stampfile depends on are out of date.
#
# See LICENCE.md for Copyright information.

include (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_TESTS_DIRECTORY}/CMakeUnit.cmake)

set (BUILD_OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/BUILD.output)

set (VERAPP_ON_SOURCE_FILE_REGEX
   "^.*vera\\+\\+.*Source\\.cpp.*$")
set (VERAPP_ON_GENERATED_FILE_REGEX
   "^.*vera\\+\\+.*Generated\\.cpp.*$")
set (CPPCHECK_ON_SOURCE_FILE_REGEX
   "^.*cppcheck.*Source\\.cpp.*$")
set (CPPCHECK_ON_GENERATED_FILE_REGEX
   "^.*cppcheck.*Generated\\.cpp.*$")
set (CLANG_TIDY_ON_SOURCE_FILE_REGEX
   "^.*clang-tidy.*Source\\.cpp.*$")
set (CLANG_TIDY_ON_GENERATED_FILE_REGEX
   "^.*clang-tidy.*Generated\\.cpp$")
set (IWYU_ON_SOURCE_FILE_REGEX
   "^.*include-what-you-use*Source\\.cpp.*$")
set (IWYU_ON_GENERATED_FILE_REGEX
   "^.*include-what-you-use.*Generated\\.cpp$")

assert_file_has_line_matching (${BUILD_OUTPUT}
                               ${VERAPP_ON_SOURCE_FILE_REGEX})
assert_file_has_line_matching (${BUILD_OUTPUT}
                               ${VERAPP_ON_GENERATED_FILE_REGEX})

assert_file_has_line_matching (${BUILD_OUTPUT}
                               ${CPPCHECK_ON_SOURCE_FILE_REGEX})
assert_file_has_line_matching (${BUILD_OUTPUT}
                               ${CPPCHECK_ON_GENERATED_FILE_REGEX})

assert_file_has_line_matching (${BUILD_OUTPUT}
                               ${CLANG_TIDY_ON_SOURCE_FILE_REGEX})
assert_file_has_line_matching (${BUILD_OUTPUT}
                               ${CLANG_TIDY_ON_GENERATED_FILE_REGEX})