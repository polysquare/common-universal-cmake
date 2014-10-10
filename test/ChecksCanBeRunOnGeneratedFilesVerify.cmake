# /tests/ChecksCanBeRunOnGeneratedFilesVerify.cmake
# Verifies that vera++ and cppcheck are run on our generated sources if
# the CHECK_GENERATED option is passed.
#
# See LICENCE.md for Copyright information.

include (CMakeUnit)

set (BUILD_OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/BUILD.output)

set (VERAPP_ON_GENERATED_FILE_REGEX
   "^.*vera\\+\\+.*Generated\\.cpp.*$")
set (CPPCHECK_ON_GENERATED_FILE_REGEX
   "^.*cppcheck.*Generated\\.cpp.*$")

assert_file_has_line_matching (${BUILD_OUTPUT}
                               ${VERAPP_ON_GENERATED_FILE_REGEX})
assert_file_has_line_matching (${BUILD_OUTPUT}
                               ${CPPCHECK_ON_GENERATED_FILE_REGEX})