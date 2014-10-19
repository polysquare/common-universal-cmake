# /test/CreateMSanInstrumentedBinaryVerify.cmake
# Verifies that we compile a binary called target_msan with -fsanitize=memory
#
# See LICENCE.md for Copyright information.

include (CMakeUnit)

set (BUILD_OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/BUILD.output)

assert_file_has_line_matching (${BUILD_OUTPUT}
                               "^.*-fsanitize=memory.*Source.cpp.*$")
assert_file_has_line_matching (${BUILD_OUTPUT}
                               "^.*-fsanitize=memory.*target_msan.*$")