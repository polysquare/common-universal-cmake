# /test/NoPCHOption.cmake
# Verifies that passing NO_PRECOMPILED_HEADERS to the target generator
# causes precompiled headers not to be generated.
#
# See LICENCE.md for Copyright information.

include (PolysquareCommon)
include (CMakeUnit)

polysquare_compiler_bootstrap ()
polysquare_acceleration_bootstrap ()

set (COTIRE_MINIMUM_NUMBER_OF_TARGET_SOURCES 1 CACHE BOOL "" FORCE)

set (SOURCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/Source.cpp)
set (HEADER_FILE ${CMAKE_CURRENT_SOURCE_DIR}/Header.h)

set (SOURCE_FILE_CONTENTS
     "#include \"Header.h\"\n"
     "int main ()\n"
     "{\n"
     "    return 0;\n"
     "}\n")

set (HEADER_FILE_CONTENTS
    "#ifndef _HEADER_H\n"
    "#define _HEADER_H\n"
    "#endif\n")

file (WRITE ${SOURCE_FILE} ${SOURCE_FILE_CONTENTS})
file (WRITE ${HEADER_FILE} ${HEADER_FILE_CONTENTS})

set (EXECUTABLE executable)

polysquare_add_executable (${EXECUTABLE}
                           SOURCES ${SOURCE_FILE}
                           INTERNAL_INCLUDE_DIRS ${CMAKE_CURRENT_SOURCE_DIR}
                           NO_PRECOMPILED_HEADERS)

assert_target_does_not_exist (${EXECUTABLE}_pch)