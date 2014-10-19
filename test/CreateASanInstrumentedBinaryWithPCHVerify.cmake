# /test/CreateASanInstrumentedBinaryWithPCHVerify.cmake
# Verifies that we compile a binary called target_asan with -fsanitize=address
#
# See LICENCE.md for Copyright information.

include (CMakeUnit)

set (BUILD_OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/BUILD.output)

assert_file_has_line_matching (${BUILD_OUTPUT}
                               "^.*-fsanitize=address.*Source.cpp.*$")
assert_file_has_line_matching (${BUILD_OUTPUT}
                               "^.*-fsanitize=address.*target_asan.*$")