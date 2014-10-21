# /test/SkipGeneratedFilesInPCHFile.cmake
#
# Places some headers in the source / build directories, but the header
# is a generated file.
#
# See LICENCE.md for Copyright information.

include (PolysquareCommon)
include (CMakeUnit)

polysquare_compiler_bootstrap ()
polysquare_acceleration_bootstrap (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY})

set (COTIRE_MINIMUM_NUMBER_OF_TARGET_SOURCES 1 CACHE BOOL "" FORCE)

set (SOURCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/Source.cpp)
set (SOURCE_FILE_CONTENTS
     "#include \"Header.h\"\n"
     "int main ()\n"
     "{\n"
     "    return 0\;\n"
     "}\n")
file (WRITE ${SOURCE_FILE} ${SOURCE_FILE_CONTENTS})

set (HEADER_FILE ${CMAKE_CURRENT_BINARY_DIR}/Header.h)
add_custom_command (OUTPUT ${HEADER_FILE}
                    COMMAND ${CMAKE_COMMAND} -E touch ${HEADER_FILE})

set (EXECUTABLE executable)

polysquare_add_executable (${EXECUTABLE}
                           SOURCES ${SOURCE_FILE} ${HEADER_FILE}
                           INTERNAL_INCLUDE_DIRS ${CMAKE_CURRENT_BINARY_DIR})