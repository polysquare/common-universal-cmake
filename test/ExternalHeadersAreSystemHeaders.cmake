# /tests/ExternalHeadersAreSystemHeaders.cmake
# Ensures that when adding EXTERNAL_INCLUDE_DIRS to a target that
# those directories are marked as system include directories.
#
# See LICENCE.md for Copyright information

include (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY}/PolysquareCommon.cmake)
include (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_TESTS_DIRECTORY}/CMakeUnit.cmake)

set (SOURCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/Source.cpp)
set (SOURCE_FILE_CONTENTS "")

file (WRITE ${SOURCE_FILE} ${SOURCE_FILE_CONTENTS})

set (INTERNAL_INCLUDE_DIR ${CMAKE_CURRENT_BINARY_DIR}/Internal)
set (EXTERNAL_INCLUDE_DIR ${CMAKE_CURRENT_BINARY_DIR}/External)

polysquare_add_library (library SHARED
                        SOURCES ${SOURCE_FILE}
                        INTERNAL_INCLUDE_DIRS ${INTERNAL_INCLUDE_DIR}
                        EXTERNAL_INCLUDE_DIRS ${EXTERNAL_INCLUDE_DIR})
