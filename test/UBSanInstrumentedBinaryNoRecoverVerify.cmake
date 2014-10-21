# /test/UBSanInstrumentedBinaryNoSanitizeRecover.cmake
# Verifies that we compile a binary called target_ubsan with
# -fsanitize=undefined and -fno-sanitize-recover
#
# See LICENCE.md for Copyright information.

include (CMakeUnit)

set (BUILD_OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/BUILD.output)

assert_file_has_line_matching (${BUILD_OUTPUT}
                               "^.*-fno-sanitize-recover.*Source.cpp.*$")
