# /tests/AddSourcesScanTarget.cmake
# Adds a new target with arbitary sources and runs rule checkers on them.
# Also forces a particular language for the source, to ensure that the rule
# checkers know what it is.
#
# See LICENCE.md for Copyright information

include (PolysquareCommon)
include (CMakeUnit)

polysquare_rules_bootstrap ()
polysquare_gmock_bootstrap ()

set (HEADER_FILE ${CMAKE_CURRENT_BINARY_DIR}/Header.h)
set (HEADER_FILE_CONTENTS
     "/* Copyright */\n"
     "#ifndef HEADER_FILE\n"
     "#define HEADER_FILE\n"
     "class A\n"
     "{\n"
     "public:\n"
     "    unsigned int i = 0\;\n"
     "}\;\n"
     "bool function ()\;\n"
     "#endif\n")
file (WRITE ${HEADER_FILE} ${HEADER_FILE_CONTENTS})

set (SOURCE_FILE ${CMAKE_CURRENT_BINARY_DIR}/Source.cpp)
set (SOURCE_FILE_CONTENTS
     "/* Copyright */\n"
     "#include \"Header.h\"\n"
     "bool function ()\n"
     "{\n"
     "    A a\;\n"
     "    return static_cast <bool> (a.i)\;\n"
     "}\n")
file (WRITE ${SOURCE_FILE} ${SOURCE_FILE_CONTENTS})

polysquare_add_checked_sources (headers_check
                                SOURCES
                                ${SOURCE_FILE}
                                ${HEADER_FILE}
                                INTERNAL_INCLUDE_DIRS
                                ${CMAKE_CURRENT_BINARY_DIR}
                                FORCE_LANGUAGE CXX)

assert_target_exists (headers_check)
