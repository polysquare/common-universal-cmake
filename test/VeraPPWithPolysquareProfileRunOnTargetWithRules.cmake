# /tests/VeraPPWithPolysquareProfileRunOnTargetWithRules.cmake
# Bootstraps polysquare's Vera++ rules and profiles and then adds
# a new executable target with VERAPP rules turned on
#
# See LICENCE.md for Copyright information

include (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY}/PolysquareCommon.cmake)
include (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_TESTS_DIRECTORY}/CMakeUnit.cmake)

polysquare_rules_bootstrap (${POLYSQUARE_COMMON_UNIVERSAL_CMAKE_DIRECTORY}
                            ${CMAKE_CURRENT_BINARY_DIR}/polysquare)

set (SOURCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/Source.cpp)
set (HEADER_FILE ${CMAKE_CURRENT_SOURCE_DIR}/Header.h)
set (SOURCE_FILE_CONTENTS
     "/* Copyright */\n"
     "#include \"Header.h\"\n"
     "bool function ()\n"
     "{\n"
     "    return true\;\n"
     "}\n")
set (HEADER_FILE_CONTENTS
     "/* Copyright */\n"
     "#ifndef HEADER_FILE\n"
     "#define HEADER_FILE\n"
     "bool function ()\;\n"
     "#endif\n")
file (WRITE ${SOURCE_FILE} ${SOURCE_FILE_CONTENTS})
file (WRITE ${HEADER_FILE} ${HEADER_FILE_CONTENTS})

polysquare_add_library (library SHARED
                        SOURCES
                        ${SOURCE_FILE}
                        ${HEADER_FILE}
                        NO_CPPCHECK
                        NO_IWYU)
