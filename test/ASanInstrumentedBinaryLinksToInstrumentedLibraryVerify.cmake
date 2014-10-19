# /test/ASanInstrumentedBinaryLinksToInstrumentedLibrary.cmake
# Verifies that we compile an executable library called executable_asan with
# -fsanitize=address and that is linked to library_asan
#
# See LICENCE.md for Copyright information.

include (CMakeUnit)

set (BUILD_OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/BUILD.output)

set (LINKER_LINE
     "^.*executable_asan.*library_asan.*$")
assert_file_has_line_matching (${BUILD_OUTPUT} ${LINKER_LINE})