# /tests/CheckSourcesReRunIfSourcesUpdated.cmake
# Specifies a list of sources to be checked as part of a group.
#
# Creates the stampfile before the build starts by writing directly to it
# but also causes a source file for the static checks which the stampfile
# depends on to be generated during the build process.
#
# A correct implementation should re-generate the stampfile and re-run the
# static checks.
#
# See LICENCE.md for Copyright information

include (PolysquareCommon)
include (CMakeUnit)

polysquare_rules_bootstrap ()

set (SOURCE_FILE_CONTENTS
     "/* Copyright */\n"
     "void function ()\n"
     "{\n"
     "}\n")
set (GENERATED_SOURCE_FILE_INPUT_CONTENTS
     ${SOURCE_FILE_CONTENTS})

set (SOURCE_FILE_NAME ${CMAKE_CURRENT_SOURCE_DIR}/Source.cpp)
set (GENERATED_SOURCE_FILE_TEMPLATE_NAME
     ${CMAKE_CURRENT_SOURCE_DIR}/Template.cpp)
set (GENERATED_SOURCE_FILE_NAME ${CMAKE_CURRENT_BINARY_DIR}/Generated.cpp)

file (WRITE ${SOURCE_FILE_NAME} ${SOURCE_FILE_CONTENTS})
file (WRITE ${GENERATED_SOURCE_FILE_TEMPLATE_NAME}
      ${GENERATED_SOURCE_FILE_INPUT_CONTENTS})

add_custom_command (OUTPUT ${GENERATED_SOURCE_FILE_NAME}
                    COMMAND
                    ${CMAKE_COMMAND} -E copy_if_different
                    ${GENERATED_SOURCE_FILE_TEMPLATE_NAME}
                    ${GENERATED_SOURCE_FILE_NAME})

add_custom_target (generated_source_file
                   DEPENDS ${GENERATED_SOURCE_FILE_NAME})

set (SOURCE_GROUP source_group)

set (STAMPFILE ${CMAKE_CURRENT_BINARY_DIR}/${SOURCE_GROUP}.stamp)
file (WRITE ${STAMPFILE} "")

set (SOURCES
     ${SOURCE_FILE_NAME}
     ${GENERATED_SOURCE_FILE_NAME})

polysquare_add_checked_sources (${SOURCE_GROUP}
                                SOURCES ${SOURCES}
                                CHECK_GENERATED)

add_dependencies (${SOURCE_GROUP} generated_source_file)