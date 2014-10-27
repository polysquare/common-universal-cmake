# /test/UseFilesInBuildDirectoryInPCHFile.cmake
#
# Places some headers in the source / build directories.
#
# See LICENCE.md for Copyright information.

include (CMakeUnit)
include (ImportCfgIntDirHelper)

set (BINARY_OUTPUT_DIR ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CFG_INTDIR}/)
set (PREFIX_HEADER_FILE
     ${BINARY_OUTPUT_DIR}/cotire/executable_CXX_prefix.cxx)

assert_file_has_line_matching (${PREFIX_HEADER_FILE}
                               "^.*Header.h.*$")
