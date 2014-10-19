# /test/UBSanInstrumentedBinaryUnsignedIntOverflowVerify.cmake
# Verifies that we compile a binary called target_ubsan with
# -fsanitize=undefined and -fsanitize=unsigned-integer-overflow
#
# See LICENCE.md for Copyright information.

include (CMakeUnit)

set (BUILD_OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/BUILD.output)
set (UNSIGNED_INT_OVERFLOW_REGEX
     "^.*-fsanitize=unsigned-integer-overflow.*Source.cpp.*$")

assert_file_has_line_matching (${BUILD_OUTPUT}
                               "${UNSIGNED_INT_OVERFLOW_REGEX}")
