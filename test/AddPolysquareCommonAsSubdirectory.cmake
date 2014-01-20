# /tests/AddPolysquareCommonAsSubdirectory.cmake
# Tests that we can add common-universal-cmake as a
# a subdirectory.
#
# See LICENCE.md for Copyright information

add_subdirectory (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY}
                  ${CMAKE_CURRENT_BINARY_DIR}/common-universal-cmake)