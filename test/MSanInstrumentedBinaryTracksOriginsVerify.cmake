# /test/MSanInstrumentedBinaryTracksOriginsVerify.cmake
# Verifies that we compile a binary called target_msan with -fsanitize=memory
# and -fsanitize-memory-track-origins=2
#
# See LICENCE.md for Copyright information.

include (CMakeUnit)

set (BUILD_OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/BUILD.output)
set (ORIGIN_TRACKING_REGEX
     "^.*-fsanitize-memory-track-origins=2.*Source.cpp.*$")

assert_file_has_line_matching (${BUILD_OUTPUT}
                               "${ORIGIN_TRACKING_REGEX}")
