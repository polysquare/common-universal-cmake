# /test/UseFilesInBuildDirectoryInPCHFile.cmake
#
# Places some headers in the source / build directories.
#
# See LICENCE.md for Copyright information.

include (CMakeUnit)

set (PREFIX_HEADER_FILE
     ${CMAKE_CURRENT_BINARY_DIR}/cotire/executable_CXX_prefix.cxx)

assert_file_has_line_matching (${PREFIX_HEADER_FILE}
                               "^.*Header.h.*$")
