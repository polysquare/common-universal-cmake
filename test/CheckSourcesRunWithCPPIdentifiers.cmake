# /tests/CheckSourcesRunWithCPPIdentifiers.cmake
# Runs checks on both a source and header file. We will use special
# C++ identifiers to mark the header file as being both compatible
# with C and C++ code.
#
# See LICENCE.md for Copyright information

include (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY}/PolysquareCommon.cmake)
include (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_TESTS_DIRECTORY}/CMakeUnit.cmake)

polysquare_rules_bootstrap (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY}
                            ${CMAKE_CURRENT_BINARY_DIR}/polysquare)

set (HEADER_FILE ${CMAKE_CURRENT_BINARY_DIR}/Header.h)
set (HEADER_FILE_CONTENTS
     "#ifndef HEADER_FILE_H\n"
     "#define HEADER_FILE_H\n"
     "#define FILE_IS_CPP\n"
     "struct A\n"
     "{\n"
     "    int i\;\n"
     "}\;\n"
     "#endif\n")

set (SOURCE_FILE ${CMAKE_CURRENT_BINARY_DIR}/Source.c)
set (SOURCE_FILE_CONTENTS
     "#include <Header.h>\n"
     "int function()\n"
     "{\n"
     "    struct A a = { 0 }\;\n"
     "    return a.i\;\n"
     "}\n")
file (WRITE ${SOURCE_FILE} ${SOURCE_FILE_CONTENTS})
file (WRITE ${HEADER_FILE} ${HEADER_FILE_CONTENTS})

polysquare_add_library (lib SHARED
                        SOURCES
                        ${SOURCE_FILE}
                        ${HEADER_FILE}
                        INTERNAL_INCLUDE_DIRS "${CMAKE_CURRENT_BINARY_DIR}"
                        CPP_IDENTIFIERS FILE_IS_CPP
                        NO_VERAPP)
