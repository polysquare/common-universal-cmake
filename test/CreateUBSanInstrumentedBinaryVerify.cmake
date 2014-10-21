# /test/CreateUBSanInstrumentedBinaryVerify.cmake
# Verifies that we compile a binary called target_ubsan with
# -fsanitize=undefined
#
# See LICENCE.md for Copyright information.

include (CMakeUnit)

set (BUILD_OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/BUILD.output)

assert_file_has_line_matching (${BUILD_OUTPUT}
                               "^.*-fsanitize=undefined.*Source.cpp.*$")
assert_file_has_line_matching (${BUILD_OUTPUT}
                               "^.*-fsanitize=undefined.*target_ubsan.*$")
