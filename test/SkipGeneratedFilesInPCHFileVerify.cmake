# /test/SkipGeneratedFilesInPCHFileVerify.cmake
#
# Places some headers in the source / build directories.
#
# See LICENCE.md for Copyright information.

include (CMakeUnit)
include (ImportCfgIntDirHelper)

set (CMAKE_BINARY_OUTPUT_DIR ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CFG_INTDIR})
set (PREFIX_HEADER_FILE
     ${CMAKE_BINARY_OUTPUT_DIR}/cotire/executable_CXX_prefix.cxx)

# The story with Ninja is slightly different - Header.h will be generated
# before the prefix header, so cotire will detect that it exists. This
# is fine - we just need to check that it both exists at this point
# and that cotire put it into the prefix header
if ("${CMAKE_GENERATOR}" STREQUAL "Ninja")

    assert_file_exists (${CMAKE_CURRENT_BINARY_DIR}/Header.h)
    assert_file_has_line_matching (${PREFIX_HEADER_FILE}
                                   "^.*Header.h.*$")

else ("${CMAKE_GENERATOR}" STREQUAL "Ninja")

    assert_file_does_not_have_line_matching (${PREFIX_HEADER_FILE}
                                             "^.*Header.h.*$")

endif ("${CMAKE_GENERATOR}" STREQUAL "Ninja")
