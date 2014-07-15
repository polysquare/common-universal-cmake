# /test/NoPCHGlobalOption.cmake
# Verifies that setting POLYSQUARE_USE_PRECOMPILED_HEADERS to FALSE
# causes precompiled headers not to be generated.
#
# See LICENCE.md for Copyright information.

include (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY}/PolysquareCommon.cmake)
include (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_TESTS_DIRECTORY}/CMakeUnit.cmake)

polysquare_compiler_bootstrap ()
polysquare_cotire_bootstrap (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY})

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

set (POLYSQUARE_USE_PRECOMPILED_HEADERS OFF CACHE BOOL "" FORCE)

polysquare_add_executable (${EXECUTABLE}
                           SOURCES ${SOURCE_FILE}
                           INTERNAL_INCLUDE_DIRS ${CMAKE_CURRENT_SOURCE_DIR})

assert_target_does_not_exist (${EXECUTABLE}_pch)